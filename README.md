# BNO055-data-collection-tools
collection of tools to visulize data from BNO055 sensor

Will include some screen shots later

Could use some refactoring to optimize stuff, thrown together in an hour or so.

## Tools Description
* **Arduino code** - upload this to your arduino, outputs data to serial in formated string (tools expect this exact format)
* **plot3D** - Live plots data from serial into 3D space, hold right click to move around
* **dataPlotter** - splits live data into separate X, Y, Z graphs. Allows you to apply filters and multiplier to data and few results
** - refactor array to list for better performence
** - remove extra for loops
