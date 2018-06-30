#!/bin/sh

#
# Get the disk temperature as reported by via smartmontools.
#
# My drive is from Seagate.
#
# According to [Seagate S.M.A.R.T. Attributes](https://www.smartmontools.org/wiki/AttributesSeagate)...
# It seems that there are 2 temperature sensor values that you can read from Seagate drives.
# You may need experiment and find which one works best for you.
#
#   - Key 190: Airflow_Temperature_Cel
#   - Key 194: HDA Temperature
#
# Pick the higher of the 2 temperature values for the internal physical disk
TEMP=$(/usr/local/bin/smartctl -A $(diskutil list |grep "(internal, physical)"| awk '{print $1}') | grep ^19[04] | awk '{print $10}' | sort -n | tail -n1)

#
# Depending on the actual temperature set a value for the desired fan speed.
#
if [ $TEMP -le 31 ]
then
	SPEED=1100
elif [ $TEMP -le 33 ]
then
	SPEED=1200
elif [ $TEMP -le 35 ]
then
	SPEED=1500
elif [ $TEMP -le 38 ]
then
	SPEED=2600
elif [ $TEMP -le 41 ]
then
	SPEED=3500
elif [ $TEMP -le 44 ]
then
	SPEED=4000
elif [ $TEMP -le 52 ]
then
	SPEED=5000
else
	SPEED=6200
fi

#
# Convert desired speed to hex.
#
HEXSPEED=$(python -c "print hex($SPEED << 2)[2:]")

#
# Print findings.
#
echo "Drive temperature is $TEMP. Setting fan speed to $SPEED"

#
# Issue command to set and force the target fan speed
#
# Note: This should work whether your fan typically runs too fast OR too slow (if your sensor is shorted)
#
/usr/local/sbin/smc -k "FS! " -w 0002
/usr/local/sbin/smc -k F1Tg -w $HEXSPEED

# End of script.
