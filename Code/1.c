/*******************************************************
This program was created by the
CodeWizardAVR V3.14 Advanced
Automatic Program Generator
© Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : Az Digital 2 Project
Version : 
Date    : 22/01/2025
Author  : 
Company : 
Comments: 


Chip type               : ATmega32
Program type            : Application
AVR Core Clock frequency: 8.000000 MHz
Memory model            : Small
External RAM size       : 0
Data Stack size         : 512
*******************************************************/

#include <mega32.h>
#include <stdbool.h>
#include <delay.h>
#include <stdio.h>
#include <twi.h>


// --------------------------------- definitions ---------------------------------------

#define LCD_I2C_ADDR       0x3F

// LM75 with A2=0, A1=1, A0=1
#define LM75_I2C_ADDR      0x4B

volatile int seconds = 0, minutes = 0, hours = 0;
volatile int second_flag = 0;  // updates when 1 second passed

int fuel_level          = 100;
int speed_value         = 0;  // from ADC (PA0)
int steering_value      = 0;  // from ADC (PA1)
//int direction           = 0;  // 0=Stop, 1=forward, -1=reverse
int brake_applied       = 0;
int headlights_on       = 0;
//int current_menu        = 0;
long int baseSpeed      = 0;
long int scaledSpeed    = 0;
long int steer_offset   = 0;
long int offsetScaled   = 0;
long int leftSpeedVal   = 0;
long int rightSpeedVal  = 0;
#define PWM_TOP 10000   // value of ICR1 to calculate pwm duty cycle
//bool lcd_timer_on       = false;
char buffer[20];
//char buffer2[20];
int temp                = 0;
int directionFlag       = 0;   // -1 => reverse, 0 => stop, +1 => forward
bool int_button_used    = false;
bool turn_brake_light   = false;
static int toggle       = 0;
int toggle_4            = 0;
char buffer_time[20];  // Enough for "HH:MM:SS"
int firstKey;
int secondKey;
bool timer_toggle = true;






//---------------------------------------------------------------------------
// Function Prototypes
//---------------------------------------------------------------------------

// Keypad
int  read_keypad_2x2(void);

// Car control helpers
void update_fuel_usage(void);
void beep_when_reverse(void);

// ------------------------ PCF8574 ----------------------------------------------------
#define LCD_EN             0x04  // Enable bit
#define LCD_RW             0x02  // Read/Write bit
#define LCD_RS             0x01  // Register Select bit
#define LCD_BACKLIGHT      0x08  // Backlight bit

//---------------------- LCD FUNCTIONS -------------------------------------------------

bool twi_lcd_write(int data)
{
    unsigned char tx_data = (unsigned char)(data & 0xFF);

    // Keep backlight on:
    tx_data |= LCD_BACKLIGHT;

    // Send 1 byte to the PCF8574
    return twi_master_trans(LCD_I2C_ADDR, &tx_data, 1, 0, 0);
}

// Send a 4-bit nibble to the LCD.
void lcd_send_nibble(int nibble, int mode)
{
    int data_out = (nibble & 0xF0) | mode; // upper nibble + RS/RW bits

    // EN=0
    twi_lcd_write(data_out);

    // Pulse EN=1
    twi_lcd_write(data_out | LCD_EN);
    delay_us(1);

    // EN=0
    twi_lcd_write(data_out & ~LCD_EN);
    delay_us(50); 
}

// Send a full byte (cmd/data) in 4-bit mode
void lcd_send_byte(int value, int mode)
{
    // High nibble
    lcd_send_nibble(value & 0xF0, mode);
    // Low nibble
    lcd_send_nibble((value << 4) & 0xF0, mode);
}

// Send a command (RS=0)
void lcd_cmd(int cmd)
{
    lcd_send_byte(cmd, 0);
}

// Send data (RS=1)
void lcd_data(int data)
{
    lcd_send_byte(data, LCD_RS);
}

void lcd_init(void)
{
    // Wait for LCD power-up
    delay_ms(20);

    // Per HD44780 init sequence: send 0x30 (8-bit mode) thrice
    lcd_send_nibble(0x30, 0);
    delay_ms(5);
    lcd_send_nibble(0x30, 0);
    delay_us(100);
    lcd_send_nibble(0x30, 0);
    delay_us(100);

    // Switch to 4-bit mode (0x20 = 4-bit)
    lcd_send_nibble(0x20, 0);
    delay_us(100);

    // Function Set: 4-bit interface, 2 (or 4) lines, 5x8 font.
    // Even for a 20×4, set N=1 => 0x28
    lcd_cmd(0x28);

    // Display off (D=0, C=0, B=0)
    lcd_cmd(0x08);

    // Clear display
    lcd_cmd(0x01);
    delay_ms(2);

    // Entry mode set: increment cursor, no shift (I/D=1, S=0)
    lcd_cmd(0x06);

    // Display on, cursor off, blink off (D=1, C=0, B=0 => 0x0C)
    lcd_cmd(0x0C);
}


// Print a string at the current cursor
void lcd_print(char *str)
{
    while (*str)
        lcd_data(*str++);
}

// Move cursor to (col, row) on a 16×2 display
// Move cursor to (col, row) on a 20×4 display
void lcd_gotoxy(int col, int row)
{
    int address;

    // Common DDRAM mapping for a 20×4 LCD:
    // Row0 => 0x00
    // Row1 => 0x40
    // Row2 => 0x14
    // Row3 => 0x54
    switch(row)
    {
        case 0: address = 0x00; break;
        case 1: address = 0x40; break;
        case 2: address = 0x14; break;
        case 3: address = 0x54; break;
        default: address = 0x00; // fallback if row is out of range
    }

    address += col; // add the column offset

    // Send "Set DDRAM address" command
    lcd_cmd(0x80 | address);
}



//-------------------------Menus codes -----------------------------------------------------

void display_time_on_lcd(void)
{

    // Format the time as "HH:MM:SS"
    sprintf(buffer_time, "%02d:%02d:%02d", hours, minutes, seconds);

    // place it at row=0, col=0
    lcd_gotoxy(0, 3);
    lcd_print("Time: ");
    lcd_print(buffer_time);
}




// ------------------------ LM75 Routines ------------------------

// Write an arbitrary register in the LM75 (e.g. config, TOS, THYST)
bool lm75_write_register(unsigned char reg, unsigned char *data, unsigned char length)
{
    // For the LM75, the first byte is the register pointer
    // The following bytes are the data to write
    unsigned char tx_buffer[1 + 2]; // up to 1 register + 2 data bytes
    unsigned char i;

    if (length > 2) return false; // LM75 typically only needs up to 2 bytes

    tx_buffer[0] = reg;
    for (i = 0; i < length; i++)
        tx_buffer[1 + i] = data[i];

    return twi_master_trans(LM75_I2C_ADDR, tx_buffer, (1 + length), 0, 0);
}

// Set the LM75 configuration register (register 1).
// For default (continuous, comparator mode, active-low OS), pass config=0.
bool lm75_write_config(unsigned char config)
{
    unsigned char data = config;
    return lm75_write_register(1, &data, 1);
}

// Set TOS (Overtemp Shutdown) register to 'tempC' degrees
bool lm75_set_tos(int tempC)
{
    // TOS is 2 bytes. In default 9-bit mode, the high byte has the sign+integer bits, 
    // and the fraction bit is bit 0. We'll ignore fractions and set TOS = tempC.0
    // So upper byte = tempC, lower byte = 0.
    //
    // Example: 70 => 0x46 => 70 decimal. 
    // This sets TOS to +70.0 °C
    unsigned char temp_data[2];
    temp_data[0] = (unsigned char)(tempC & 0x7F); // sign=0, store up to 127
    temp_data[1] = 0x00;

    return lm75_write_register(3, temp_data, 2); // TOS register = 3
}

// Read the LM75 temperature (register 0) as an integer.
// If 9-bit resolution (default), bit 7 of the lower byte is the 0.5 fraction bit.
int lm75_read_temp(void)
{
    unsigned char reg_pointer = 0;  // Temperature register = 0
    unsigned char rx_data[2];
    int tempC = 0;

    // First, set the register pointer to 0 with a write transaction
    // but we don't send any data beyond the pointer.
    if (!twi_master_trans(LM75_I2C_ADDR, &reg_pointer, 1, 0, 0))
        return -1000; // indicate error

    // Now read 2 bytes from the temperature register
    // (rx_data[0] = MSB, rx_data[1] = LSB)
    if (!twi_master_trans(LM75_I2C_ADDR, 0, 0, rx_data, 2))
        return -1000; // indicate error

    // In default 9-bit mode:
    //  rx_data[0] bit 7 => sign (0 = positive)
    //  rx_data[0] bits 6..0 => integer portion
    //  rx_data[1] bit 7 => 0.5 fraction
    //  We will do a simple rounding or floor approach.

    // Check sign bit (bit 7 of rx_data[0]):
    if (rx_data[0] & 0x80)
    {
        // Negative temperature (simple approach). 
        // We won't fully implement negative decoding here, but you could.
        return -999; // Or do a real sign extension
    }
    else
    {
        // Positive: integer portion is bits 6..0
        tempC = (rx_data[0] & 0x7F); // 0..127
        // If the fraction bit is set, we might add +0.5 or round up
        // We'll do simple rounding to the nearest integer
        if (rx_data[1] & 0x80) 
        {
            // fraction = 0.5 => round up
            tempC += 1;
        }
    }
    return tempC; 
}
// ------------------------ LM75 Routines end------------------------


// ---------------------------keypad---------------------------------
int read_keypad_2x2(void)
{
    int key = 0;

    //--- 1) Enable pull-ups on PA6..PA7 (the columns) ---
    PORTA |= (1<<6) | (1<<7);

    //--- 2) Drive Row0=low (PA4=0), Row1=high (PA5=1) ---
    PORTA &= ~(1<<4);  // row0=0
    PORTA |=  (1<<5);  // row1=1
    delay_ms(5);       // wait a bit for signals to settle

    // Check column lines (PA6, PA7)
    if(!(PINA & (1<<6))) key = 1;  // Row0/Col0 => Key1
    if(!(PINA & (1<<7))) key = 2;  // Row0/Col1 => Key2

    //--- 3) Drive Row0=high (PA4=1), Row1=low (PA5=0) ---
    PORTA |=  (1<<4);
    PORTA &= ~(1<<5);
    delay_ms(5);

    // Check columns again
    if(!(PINA & (1<<6))) key = 3;  // Row1/Col0 => Key3
    if(!(PINA & (1<<7))) key = 4;  // Row1/Col1 => Key4

    //--- 4) Restore rows high (optional) ---
    PORTA |= (1<<4) | (1<<5);

    return key;
}


int read_keypad_2x2_debounced(void)
{
    // 1) Read raw key
    firstKey = read_keypad_2x2();
    
    // 2) If no key is pressed => return 0
    if(firstKey == 0)
        return 0;

    // 3) Wait a short debounce time
    delay_ms(30);  // ~20ms is typical
    
    // 4) Read again
    secondKey = read_keypad_2x2();

    // 5) If they match, return that key
    if(secondKey == firstKey)
        return firstKey;

    // 6) Otherwise, ignore (bounce) => return 0
    return 0;
}

//---------------------------------------------------------------------------
// Decrement fuel ~ once per second if direction != 0
//---------------------------------------------------------------------------
void update_fuel_usage(void)
{
    if(directionFlag!=0)
    {
        if(fuel_level>0) fuel_level--;
    }
}

//---------------------motor control ----------------------------------------
void beep_when_reverse(void)
{
    toggle = !toggle;

    if(toggle)
        PORTC |=  (1<<6);
    else
        PORTC &= ~(1<<6);

    delay_ms(50);
    
    PORTC &= ~(1<<6);  // ensure off
}

void setLeftMotorDirection(int forward)
{
    // If forward=1 => forward
    // If forward=-1 => reverse
    // If forward=0 => stop
    // Example for 2 motors on left side sharing in1..in4
    if(forward == 1)
    {
        // PC2=1, PC3=0, PC4=1, PC5=0 => forward
        PORTC |=  (1<<2);
        PORTC &= ~(1<<3);
        PORTC |=  (1<<4);
        PORTC &= ~(1<<5);
    }
    else if(forward == -1)
    {
        // PC2=0, PC3=1, PC4=0, PC5=1 => reverse
        PORTC &= ~(1<<2);
        PORTC |=  (1<<3);
        PORTC &= ~(1<<4);
        PORTC |=  (1<<5);
    }
    else
    {
        // Stop: clear all
        PORTC &= ~((1<<2)|(1<<3)|(1<<4)|(1<<5));
    }
}

void setLeftMotorSpeed(long int duty)
{
    if(duty < 0) duty = 0;
    if(duty > PWM_TOP) duty = PWM_TOP;
    OCR1A = duty; // PD5 => left side motors
}

void setRightMotorSpeed(long int duty)
{
    if(duty < 0) duty = 0;
    if(duty > PWM_TOP) duty = PWM_TOP;
    OCR1B = duty; // PD4 => right side motors
}

void setRightMotorDirection(int forward)
{
    if(forward == 1)
    {
        // PB4=1, PB5=0, PB6=1, PB7=0 => forward
        PORTB |=  (1<<4);
        PORTB &= ~(1<<5);
        PORTB |=  (1<<6);
        PORTB &= ~(1<<7);
    }
    else if(forward == -1)
    {
        // PB4=0, PB5=1, PB6=0, PB7=1 => reverse
        PORTB &= ~(1<<4);
        PORTB |=  (1<<5);
        PORTB &= ~(1<<6);
        PORTB |=  (1<<7);
    }
    else
    {
        // Stop
        PORTB &= ~((1<<4)|(1<<5)|(1<<6)|(1<<7));
    }
}

//---------------------motor control end --------------------------------------

                      
// External Interrupt 2 service routine
interrupt [EXT_INT2] void ext_int2_isr(void)
{
    printf("interrupt 2\n\r");
    brake_applied = 1;
    int_button_used=!int_button_used;
}

// Timer 0 overflow interrupt service routine
interrupt [TIM0_OVF] void timer0_ovf_isr(void)
{
    static int count = 0;
    count++;

    // ~31 overflows per second
    if(count >= 31)
    {
        count = 0;
        seconds++;
        if(seconds >= 60)
        {
            seconds=0;
            minutes++;
            if(minutes >= 60)
            {
                minutes = 0;
                hours++;
                if(hours >= 24) hours=0;
            }
        }
        // Decrement fuel if direction != 0 
               update_fuel_usage();
            
        second_flag = 1;

    }
}

// Voltage Reference: AREF pin
#define ADC_VREF_TYPE ((0<<REFS1) | (0<<REFS0) | (0<<ADLAR))

// Read the AD conversion result
unsigned int read_adc(unsigned char adc_input)
{
ADMUX=adc_input | ADC_VREF_TYPE;
// Delay needed for the stabilization of the ADC input voltage
delay_us(10);
// Start the AD conversion
ADCSRA|=(1<<ADSC);
// Wait for the AD conversion to complete
while ((ADCSRA & (1<<ADIF))==0);
ADCSRA|=(1<<ADIF);
return ADCW;
}


void updateMotorControl(void)
{
    // 1) Read speed pot
    int speed_adc = read_adc(0);  // 0..1023
    // 2) Read steering pot
    int steer_adc = read_adc(1);  // 0..1023

    // 3) Decide direction

    if(speed_adc > 512)
        directionFlag = 1;
    else if(speed_adc < 512)
        directionFlag = -1;
    else
        directionFlag = 0;

    // 4) Base speed = difference from 512 (max ~511)
    //    map 0..511 => 0..PWM_TOP
    baseSpeed = (directionFlag == 0) ? 0 : (speed_adc - 512);
    if(directionFlag == -1)
        baseSpeed = 512 - speed_adc; // if going reverse, speed is how far below 512

    if(baseSpeed < 0) baseSpeed = -baseSpeed; // just in case

    // Scale to 0..PWM_TOP
    // baseSpeed * PWM_TOP / 511
    scaledSpeed = (baseSpeed * PWM_TOP) / 511;
    if(scaledSpeed < 0) scaledSpeed = 0;
    if(scaledSpeed > PWM_TOP) scaledSpeed = PWM_TOP;

    // 5) Steering offset
    // steer_adc ~ 0..1023
    // If <512 => left turn => left side slower, right side faster
    // If >512 => right turn => left side faster, right side slower
    // If =512 => no offset
    steer_offset = steer_adc - 512; // range ~ -512..+511

    // leftSpeed = scaledSpeed - offset
    // rightSpeed= scaledSpeed + offset
    // offsetScaled = (steer_offset * PWM_TOP) / 512
    offsetScaled = (steer_offset * PWM_TOP) / 512;
    leftSpeedVal  = scaledSpeed - offsetScaled;
    rightSpeedVal = scaledSpeed + offsetScaled;

    // clamp them
    if(leftSpeedVal < 0)   leftSpeedVal = 0;
    if(leftSpeedVal > PWM_TOP)  leftSpeedVal = PWM_TOP;
    if(rightSpeedVal < 0)  rightSpeedVal = 0;
    if(rightSpeedVal > PWM_TOP) rightSpeedVal = PWM_TOP;

    // 6) Set directions
    // If directionFlag= 1 => forward. If -1 => reverse. If 0 => stop all.
    setLeftMotorDirection(directionFlag);
    setRightMotorDirection(directionFlag);

    // 7) Set speeds (PWM)
    if(directionFlag == 0)
    {
        // Stopped
        setLeftMotorSpeed(0);
        setRightMotorSpeed(0);
    }
    else if((brake_applied)&&(directionFlag!=0)) //Brake logic
        {    
              setLeftMotorSpeed(0); // Stopped
              setRightMotorSpeed(0); // Stopped
              setLeftMotorDirection(0);
              setRightMotorDirection(0);
              turn_brake_light = true;
              printf("[DBG] Brake applied.\r\n");
            
            if((int_button_used== false)&&(brake_applied))
            {
                brake_applied=0;
                turn_brake_light = false;
                printf("[DBG] Brake released.\r\n");
            }
        }
    else if(temp>70)
    {
              setLeftMotorSpeed(0); // Stopped
              setRightMotorSpeed(0); // Stopped
              setLeftMotorDirection(0);
              setRightMotorDirection(0);
    }
    else
    {
        setLeftMotorSpeed(leftSpeedVal);
        setRightMotorSpeed(rightSpeedVal);
    }
}

void lcd_display(void){
                    sprintf(buffer,"speed:   %d", speed_value);
                    lcd_gotoxy(0,0);
                    lcd_print(buffer);
                    sprintf(buffer,"temp:   %d", temp);
                    lcd_gotoxy(0,1);     
                    lcd_print(buffer);
                    sprintf(buffer,"fuel:   %d", fuel_level);
                    lcd_gotoxy(0,2);
                    lcd_print(buffer);
                    if(timer_toggle){
                    display_time_on_lcd();}
}

void main(void)
{
// -----------------------------------Declare your local variables here-----------------------------------------





//--------------------------------------------------------------------------------------------------------------

// Input/Output Ports initialization
{
// Port A initialization
// Function: Bit7=In Bit6=In Bit5=out Bit4=out Bit3=In Bit2=In Bit1=In Bit0=In 
DDRA=(0<<DDA7) | (0<<DDA6) | (1<<DDA5) | (1<<DDA4) | (0<<DDA3) | (0<<DDA2) | (0<<DDA1) | (0<<DDA0);
// State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T 
PORTA=(0<<PORTA7) | (0<<PORTA6) | (1<<PORTA5) | (1<<PORTA4) | (0<<PORTA3) | (0<<PORTA2) | (0<<PORTA1) | (0<<PORTA0);

// Port B initialization
// Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=In Bit0=In 
DDRB=(1<<DDB7) | (1<<DDB6) | (1<<DDB5) | (1<<DDB4) | (1<<DDB3) | (1<<DDB2) | (0<<DDB1) | (0<<DDB0);
// State: Bit7=0 Bit6=0 Bit5=0 Bit4=0 Bit3=1 Bit2=1 Bit1=T Bit0=T 
PORTB=(0<<PORTB7) | (0<<PORTB6) | (0<<PORTB5) | (0<<PORTB4) | (1<<PORTB3) | (1<<PORTB2) | (0<<PORTB1) | (0<<PORTB0);

// Port C initialization
// Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=In Bit0=In 
DDRC=(1<<DDC7) | (1<<DDC6) | (1<<DDC5) | (1<<DDC4) | (1<<DDC3) | (1<<DDC2) | (0<<DDC1) | (0<<DDC0);
// State: Bit7=0 Bit6=0 Bit5=0 Bit4=0 Bit3=0 Bit2=0 Bit1=T Bit0=T 
PORTC=(0<<PORTC7) | (0<<PORTC6) | (0<<PORTC5) | (0<<PORTC4) | (0<<PORTC3) | (0<<PORTC2) | (0<<PORTC1) | (0<<PORTC0);

// Port D initialization
// Function: Bit7=In Bit6=Out Bit5=Out Bit4=Out Bit3=In Bit2=In Bit1=In Bit0=In 
DDRD=(0<<DDD7) | (1<<DDD6) | (1<<DDD5) | (1<<DDD4) | (0<<DDD3) | (0<<DDD2) | (0<<DDD1) | (0<<DDD0);
// State: Bit7=T Bit6=0 Bit5=0 Bit4=0 Bit3=T Bit2=T Bit1=T Bit0=T 
PORTD=(0<<PORTD7) | (0<<PORTD6) | (0<<PORTD5) | (0<<PORTD4) | (0<<PORTD3) | (0<<PORTD2) | (0<<PORTD1) | (0<<PORTD0);
}

// Timer/Counter 0 initialization
{
// Clock source: System Clock
// Clock value: 7.813 kHz
// Mode: Normal top=0xFF
// OC0 output: Disconnected
// Timer Period: 32.768 ms
TCCR0=(0<<WGM00) | (0<<COM01) | (0<<COM00) | (0<<WGM01) | (1<<CS02) | (0<<CS01) | (1<<CS00);
TCNT0=0x00;
OCR0=0x00;
}
// Timer/Counter 1 initialization
{
// Clock source: System Clock
// Clock value: 1000.000 kHz
// Mode: Ph. & fr. cor. PWM top=ICR1
// OC1A output: Inverted PWM
// OC1B output: Inverted PWM
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer Period: 0.1 s
// Output Pulse(s):
// OC1A Period: 0.1 s Width: 0 us
// OC1B Period: 0.1 s Width: 0 us
// Timer1 Overflow Interrupt: Off
// Input Capture Interrupt: Off
// Compare A Match Interrupt: Off
// Compare B Match Interrupt: Off
//TCCR1A=(1<<COM1A1) | (1<<COM1A0) | (1<<COM1B1) | (1<<COM1B0) | (0<<WGM11) | (0<<WGM10);
//TCCR1B=(0<<ICNC1) | (0<<ICES1) | (1<<WGM13) | (0<<WGM12) | (0<<CS12) | (1<<CS11) | (0<<CS10);
//TCNT1H=0x00;
//TCNT1L=0x00;
//ICR1H=0xC3;
//ICR1L=0x50;
//OCR1AH=0xC3;
//OCR1AL=0x50;
//OCR1BH=0xC3;
//OCR1BL=0x50;

// Timer/Counter 1 initialization
// Clock source: System Clock
// Clock value: 1000.000 kHz
// Mode: Fast PWM top=ICR1
// OC1A output: Non-Inverted PWM
// OC1B output: Non-Inverted PWM
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer Period: 10 ms
// Output Pulse(s):
// OC1A Period: 10 ms Width: 0 us
// OC1B Period: 10 ms Width: 0 us
// Timer1 Overflow Interrupt: Off
// Input Capture Interrupt: Off
// Compare A Match Interrupt: Off
// Compare B Match Interrupt: Off
TCCR1A=(1<<COM1A1) | (0<<COM1A0) | (1<<COM1B1) | (0<<COM1B0) | (1<<WGM11) | (0<<WGM10);
TCCR1B=(0<<ICNC1) | (0<<ICES1) | (1<<WGM13) | (1<<WGM12) | (0<<CS12) | (1<<CS11) | (0<<CS10);
TCNT1H=0x00;
TCNT1L=0x00;
ICR1H=0x27;
ICR1L=0x10;
OCR1AH=0x00;
OCR1AL=0x00;
OCR1BH=0x00;
OCR1BL=0x00;

}
// Timer(s)/Counter(s) Interrupt(s) initialization
TIMSK=(0<<OCIE2) | (0<<TOIE2) | (0<<TICIE1) | (0<<OCIE1A) | (0<<OCIE1B) | (0<<TOIE1) | (0<<OCIE0) | (1<<TOIE0);

// External Interrupt(s) initialization
{
// INT0: Off
// INT1: Off
// INT2: On
// INT2 Mode: Rising Edge
GICR|=(0<<INT1) | (0<<INT0) | (1<<INT2);
MCUCR=(0<<ISC11) | (0<<ISC10) | (0<<ISC01) | (0<<ISC00);
MCUCSR=(1<<ISC2);
GIFR=(0<<INTF1) | (0<<INTF0) | (1<<INTF2);
}
// USART initialization
{
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART Receiver: Off
// USART Transmitter: On
// USART Mode: Asynchronous
// USART Baud Rate: 9600
UCSRA=(0<<RXC) | (0<<TXC) | (0<<UDRE) | (0<<FE) | (0<<DOR) | (0<<UPE) | (0<<U2X) | (0<<MPCM);
UCSRB=(0<<RXCIE) | (0<<TXCIE) | (0<<UDRIE) | (0<<RXEN) | (1<<TXEN) | (0<<UCSZ2) | (0<<RXB8) | (0<<TXB8);
UCSRC=(1<<URSEL) | (0<<UMSEL) | (0<<UPM1) | (0<<UPM0) | (0<<USBS) | (1<<UCSZ1) | (1<<UCSZ0) | (0<<UCPOL);
UBRRH=0x00;
UBRRL=0x33;
}
// ADC initialization
{
// ADC Clock frequency: 1000.000 kHz
// ADC Voltage Reference: AREF pin
// ADC Auto Trigger Source: ADC Stopped
ADMUX=ADC_VREF_TYPE;
ADCSRA=(1<<ADEN) | (0<<ADSC) | (0<<ADATE) | (0<<ADIF) | (0<<ADIE) | (0<<ADPS2) | (1<<ADPS1) | (1<<ADPS0);
SFIOR=(0<<ADTS2) | (0<<ADTS1) | (0<<ADTS0);
}
// TWI initialization
{
// Mode: TWI Master
// Bit Rate: 400 kHz
    twi_master_init(400);

}
// Initialize the LCD
    {
    lcd_init();
    lcd_cmd(0x01); // Clear display
    }
// Configure the LM75:
{
    // 1) Put the config register = 0 => default: comparator mode, active-low OS, 9-bit, continuous
    lm75_write_config(0x00);
    // 2) Set TOS = 70 °C
    lm75_set_tos(70);
}
// Print initial message
{
    lcd_gotoxy(0, 0);
    lcd_print(" System Init...\r\n");
    lcd_gotoxy(0, 1);
    lcd_print(" Tcrit=70C");
    lcd_cmd(0x01); // Clear     
    lcd_print(" MehrzadGolabi");
    lcd_gotoxy(0, 1);
    lcd_print(" AZ Digital2 prj");
    lcd_gotoxy(0, 2);
    lcd_print(" SBU");
    lcd_gotoxy(0, 3);
    lcd_print(" 1403");
    delay_ms(1500);
    lcd_cmd(0x01); // Clear
 
}

// Global enable interrupts
#asm("sei")

while (1)
      {
      // Read ADC
        speed_value    = read_adc(0); // pot on PA0
        steering_value = read_adc(1); // pot on PA1
      
      // Temp
      temp = lm75_read_temp();
      
      // Debug stuff
      printf("Speed=%d, Steering=%d, Temp=%d, Fuel=%d, directionFlag=%d , Brake=%d\r\n",
       speed_value, steering_value, temp, fuel_level, directionFlag, brake_applied);    
      
      // keyboard handle menu, toggles, etc.
        {
            int key = read_keypad_2x2_debounced();
            switch(key)
            {
                case 1:
                    printf("[DBG] Key1\r\n");
                    lcd_cmd(0x01);
                break;

                case 2:
                    timer_toggle=!(timer_toggle);
                    printf("[DBG] Key2\r\n");
                    lcd_cmd(0x01);
                break;

                case 3:
                    // Toggle headlights (PD6)
                    headlights_on = !headlights_on;
                    if(headlights_on)
                        PORTD |=  (1<<6);
                    else
                        PORTD &= ~(1<<6);
                    printf("[DBG] Key3 => headlights_on=%d\r\n", headlights_on);
                    lcd_cmd(0x01);
                break;

                case 4:
                    toggle_4=!toggle_4;
                    if(toggle_4)
                        PORTC |=  (1<<6);
                    else
                        PORTC &= ~(1<<6);
                    printf("[DBG] Key4 => honk\r\n", toggle_4);
                    lcd_cmd(0x01);
                break;

                default:
                    // No key
                break;
            }
        }
         
      // Brake light => PC7
        if(turn_brake_light)
            PORTC |=  (1<<7);
        else
            PORTC &= ~(1<<7);
       
      // Motor Control
       updateMotorControl();
       
      // Beeping 
       if (directionFlag==-1)
       {
              beep_when_reverse();
       }

       // LCD logic
        if(second_flag) // handle menu updates once per second
        {
            second_flag = 0;  // reset the flag
            lcd_display();                   
        }
       

        delay_ms(100);
      
      }
}


