# megalog
Turn Megasquirt logs into an ingestible format.

# Why
Megasquirt spits out logs that are roughly somewhere between a traditional CSV and a time-series application log. If you want to utilize most any analytics software you can either do on the fly transformations to tag the fields, or you can transform the data before you ingest it. That what the aim here is to do, fix it before absorbing it.

# Limitations
As of right now, there are many. For one, I've only tested against one log format, and there are many within the megasquirt ecosystem. While I've tried to keep it generic and just crawl the fields I'm sure something will break. There's also the limitation that I'm just throwing out the field measurement definitions. You won't know if you're looking at temps in celcius or farenheit. This might be fixable once I figure out the proper way to add that appropriately to key=value pairs for systems like Splunk. Also, ECU's other than megasquirt have the same problem of generating poorly tagged data, but right now this only works for megasquirt. In theory it could be expanded to include other log formats on it's input.
