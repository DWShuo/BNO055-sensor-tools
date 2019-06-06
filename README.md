# BNO055-data-collection-tools
Collection of data visulization tools for the BNO055 IMU sensor
* BNO055 - [Data Sheet](https://cdn-shop.adafruit.com/datasheets/BST_BNO055_DS000_12.pdf)

Will include some screen shots later

Could do with some refactoring and optimizing, thrown together in an hour or so.

## Tools Description
* **Arduino code** - upload this to your arduino, outputs data to serial in formated string (tools expect this exact format)
* **plot3D** - Live plots data from serial into 3D space, hold right click to move around
* **data_to_file** - python script writes serial output to csv file
* **dataPlotter** - splits live data into separate X, Y, Z graphs. Allows you to apply filters and multiplier to data and few results
