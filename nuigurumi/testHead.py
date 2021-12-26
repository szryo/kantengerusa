import pigpio
import time

gpio_head = 19

pi = pigpio.pi()
pi.set_mode(gpio_head, pigpio.OUTPUT)

# GPIO18: 20Hz、duty比0.5
#pi.hardware_PWM(gpio_pin0, 50, 300000)
#pi.hardware_PWM(gpio_pin1, 50, 300000)

pi.set_servo_pulsewidth(gpio_head,2000)
time.sleep(2)
pi.set_servo_pulsewidth(gpio_head, 900)
time.sleep(5)
pi.set_servo_pulsewidth(gpio_head,2000)
time.sleep(1)

pi.set_mode(gpio_regs, pigpio.INPUT)
pi.set_mode(gpio_head, pigpio.INPUT)
pi.set_mode(gpio_right, pigpio.INPUT)
pi.set_mode(gpio_left, pigpio.INPUT)
pi.stop()