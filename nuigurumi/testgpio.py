import pigpio
import time

gpio_pin0 = 19
gpio_pin1 = 18

pi = pigpio.pi()
pi.set_mode(gpio_pin0, pigpio.OUTPUT)
pi.set_mode(gpio_pin1, pigpio.OUTPUT)

# GPIO18: 20Hz、duty比0.5
#pi.hardware_PWM(gpio_pin0, 50, 300000)
#pi.hardware_PWM(gpio_pin1, 50, 300000)
pi.set_servo_pulsewidth(gpio_pin0, 500)
pi.set_servo_pulsewidth(gpio_pin1, 2000)

print("1")
time.sleep(0.5)
#pi.set_servo_pulsewidth(gpio_pin0, 2000)
#pi.set_servo_pulsewidth(gpio_pin1, 500)

time.sleep(0.5)

#pi.set_servo_pulsewidth(gpio_pin0, 500)
#pi.set_servo_pulsewidth(gpio_pin1, 2000)
#time.sleep(0.5)

#pi.set_servo_pulsewidth(gpio_pin0, 2000)
#pi.set_servo_pulsewidth(gpio_pin1, 500)

time.sleep(0.5)
#pi.set_servo_pulsewidth(gpio_pin0, 500)
#pi.set_servo_pulsewidth(gpio_pin1, 2000)
time.sleep(0.5)

pi.set_servo_pulsewidth(gpio_pin0, 1450)
pi.set_servo_pulsewidth(gpio_pin1, 1450)

time.sleep(0.5)

#pi.set_mode(gpio_pin0, pigpio.INPUT)
#pi.set_mode(gpio_pin1, pigpio.INPUT)

pi.stop()
