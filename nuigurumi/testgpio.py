import pigpio
import time

gpio_head = 19
gpio_right = 18
gpio_regs = 12
gpio_left = 13

pi = pigpio.pi()
pi.set_mode(gpio_left, pigpio.OUTPUT)
pi.set_mode(gpio_right, pigpio.OUTPUT)

pi.set_servo_pulsewidth(gpio_left, 1450)
pi.set_servo_pulsewidth(gpio_right, 1450)

print("initialize")
time.sleep(5)

pi.set_servo_pulsewidth(gpio_left, 1000)
pi.set_servo_pulsewidth(gpio_right, 1900)

print('hold')
time.sleep(5)

pi.set_servo_pulsewidth(gpio_left, 1450)
pi.set_servo_pulsewidth(gpio_right, 1450)

print("open")

time.sleep(0.5)

pi.set_mode(gpio_regs, pigpio.INPUT)
pi.set_mode(gpio_head, pigpio.INPUT)
pi.set_mode(gpio_right, pigpio.INPUT)
pi.set_mode(gpio_left, pigpio.INPUT)

pi.stop()
