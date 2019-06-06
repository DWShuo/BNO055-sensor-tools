import serial
import syslog
import time
import csv

#Assuming you are on linux is probably /dev/ttyACM* or /dev/ttyUSB*
PORT = '/dev/ttyUSB0'
arduino = serial.Serial(PORT,115200)
time.sleep(2) #wait on arduino
arduino.flushInput()

def data_parse(data):
    data = msg_decode.split("\r\n")                     #split at new line
    data = [x.rstrip() for x in data]                   #strip white space
    data = list(filter(None, data))                     #filter out blank data
    data = [x.split('|') for x in data]                 #split by |
    data_type = [x.pop(0) for x in data][0]             #strip data type and store in var
    data = [[y.split("=")[-1] for y in x] for x in data]  #nest list comprehesnion to strip x ,y, z
    return data


if __name__ == "__main__":
    with open("data.csv", mode="w") as data_file:
        data_writer = csv.writer(data_file)
        while True:
            time.sleep(1)
            # Serial read
            msg = arduino.read(arduino.inWaiting())
            msg_decode = msg.decode("utf-8")

            data = data_parse(msg_decode)
            print(data)
            data_writer.writerows(data)
            data_file.flush()
            arduino.flushInput()
        else:
            exit()
