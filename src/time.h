#ifndef PI_LIB_TIME
#define PI_LIB_TIME

// Delays for for the specified nubmer of microseconds.
inline void delayMicroseconds(uint16_t microseconds)
{
    __asm__ volatile (
        "1: push r22"     "\n\t"
        "   ldi  r22, 4"  "\n\t"
        "2: dec  r22"     "\n\t"
        "   brne 2b"      "\n\t"
        "   pop  r22"     "\n\t"   
        "   sbiw %0, 1"   "\n\t"
        "   brne 1b"
        : "=w" ( microseconds )  
        : "0" ( microseconds )
    );  
}

inline void delay(uint16_t ms)
{
    while (ms--)
      delayMicroseconds(1000);
}

uint32_t g_timer = 0;

uint32_t getTicksCount()
{
    cli();
    uint32_t time = g_timer;
    sei();
    return time;
}

void resetTicks()
{
    cli();
    g_timer = 0;
    sei();
}

void init_timer()
{ 
    // Setup timer to 1 ms
    TCCR1B = (1 << WGM12) | (1 << CS11);
    
    OCR1AH = (1250 >> 8);
    OCR1AL = (1250 & 0xFF);
    
    TIMSK1 |=(1<<OCIE1A);
}

void clean_timer()
{
    TCCR1A = 0;
    TCCR1B = 0;
}

ISR(TIMER1_COMPA_vect)
{
    ++g_timer;

    buzzer.update();

    if(detail::g_speed_is_setted)
        return;
    detail::g_speed_is_setted = true;
    for(uint8_t i = 0; i < 2; ++i)
    {
        if(!detail::g_need_set_speed[i])
            continue;
       
        if(detail::g_speed[i] == detail::g_speed_cur[i])
        {
            detail::g_need_set_speed[i] = false;
            continue;
        }
       
        int16_t val = abs(detail::g_speed[i]-detail::g_speed_cur[i]);
        if(val >= MOTORS_ACCELERATION)
            val = MOTORS_ACCELERATION;
       
        if(detail::g_speed[i] < detail::g_speed_cur[i])
            val *= -1;
        detail::g_speed_cur[i] += val;
        setMotorPowerID(i, detail::g_speed_cur[i]);
    }
    detail::g_speed_is_setted = false;
}

#endif
