# ESP8266-Wifi-Relay

## Spezifikation

- WLAN steuerbares 2-Port Relais / oder nur mit 1 Relais bestückt
- optionale Schalter/Taster Unterstützung (inkl. Feedback)
- Firmware: [NodeMCU](https://github.com/nodemcu/nodemcu-firmware/blob/master/README.md) 
- Bestellung über [eBay](http://www.ebay.de/itm/321975116906?var=&ssPageName=STRK:MESELX:IT&_trksid=p3984.m1558.l2649) in verschienden Varianten oder per [Mail](mailto:jan.andrea7@googlemail.com)

## Installation

![Anschluss](/pics/anschluss.png?raw=true)

![Achtung](/pics/achtung-red.png?raw=true) Sobald **L/N** (~230V) angeschlossen sind und **Netzspannung** anliegt, die Platine nicht mehr berühren!

## Konfiguration

### Quick Setup

A) Beim ersten Start des ESP8266-Wifi-Relay wird ein **HOTSPOT** (nach ca. 10 Sekunden leuchtet die Blaue LED am ESP8266 3x kurz / das Relais schaltet 3x) mit der SSID: **RelaySetup** erstellt. Sobald man mit diesem Hotspot verbunden ist, kann man auf `http://192.168.4.1/set` die Zugangsdaten des eigenen WLAN-Netzes eingeben. Nach dem Speichern der Daten, startet der ESP8266 neu und versucht sich zu verbinden. Im Fehlerfall (WLAN nicht erreichbar, Zugangsdaten falsch) beginnt das ESP8266-Wifi-Relay wieder bei Schritt **A)**

Sofern alles geklappt hat, startet der TCP-Server auf Port 9274 und es können Befehle ausführt werden (z.b. Dateien auf den ESP8266 übertragen - siehe Befehls-Tabelle weiter unten)

![HOTSPOT](/pics/ssid.jpg?raw=true)
![Config-Page](/pics/set.jpg?raw=true)

### Legacy Setup

Als ersten Schritt **GND**, **RX**, **TX** mit einem [TTL-USB Adapter](http://www.elecfreaks.com/wiki/index.php?title=USB_to_RS232_Converter) (**Achtung**: 3.3 Volt Pegel, bei 5 Volt muss ein [Pegelwandler](https://www.mikrocontroller.net/articles/Pegelwandler) "Levelshifter" verwendet werden) verbinden. **RX** wird mit **TX** verbunden und **TX** mit **RX**. Dann **L**, **N** anschließen (siehe Anschlussplan).

Sobald Netz-Spannung anliegt, sollte der ESP8266 auf der Rückseite der Platine starten und die blaue LED kurz aufblinken. Jetzt habt ihr die Möglichkeit die eigentliche Steuerungs-Software ([aktor.lua](/lua-tcp/aktor.lua)) auf dem ESP8266 zu übertragen.

Dazu bitte die [aktor.lua](/lua-tcp/aktor.lua) öffen, die WLAN Daten anpassen und die Datei mit dem [ESPlorer](http://esp8266.ru/esplorer/) auf den ESP8266 kopieren (über *Save* im ESPlorer). Nach dem erfolgreichen Übertragen, wird automatisch der TCP-Server gestartet und es wird die IP vom ESP8266 angezeigt (rechtes Fenster).

![ESPlorer](/pics/esplorer.png?raw=true)


## Pimatic

Um das ESP8266-Wifi-Relay via Pimatic anzusteuern, ist folgende anpassung erforderlich:

- Ändert in der [aktor.lua](/lua-tcp/aktor.lua) Zeile 1 - 7 wiefolgt ab:

```
-- pimatic-edition 02.02.2016
version = "0.3.2.pimatic"
verriegelung = 0 -- 0 = inaktiv 1=aktiv
sid1 = "Licht_Arbeitszimmer"
sid2 = "Schlafzimmer_Lampe1"
PimaticServer = "192.168.8.200"
BaseLoginPimatic = "YWRtaW46YzRqc2luOGQ="

```

- Konfiguriert nun folgede Zeilen und Speichert die aktor.lua auf dem ESP8266:
  - sid1               -- device-id des Pimatic-Schalters, der Relais 1 schalten soll
  - sid2               -- (falls vorhanden) device-id des Pimatic-Schalters, der Relais 2 schalten soll
  - PimaticServer      -- IP eures Pimatic-Servers
  - BaseLoginPimatic   -- Base64-codierter String des Loginschemas "user:passwort" -> Um die Base64Login-Daten zu erhalten, gebt eure Loginschema auf https://www.base64encode.org/ ein und drückt "encode"
 
- Kopiert nun die tcp.php auf euer RaspberryPi (hier im Beispiel /home/pi/tcp.php) z.b. mit  ```wget https://raw.githubusercontent.com/JanGoe/esp8266-wifi-relay/master/tcp.php```
- Stellt sicher dass php5 am RaspberryPi installiert ist (ggf. "sudo apt-get install php5") 
- Anschließend fügt ihr folgende Device der Pimatic-Konfiguration an:

  ```
      {
      "id": "Licht_Arbeitszimmer",
      "name": "Lamp",
      "class": "ShellSwitch",
      "onCommand": "php /home/pi/tcp.php 192.168.8.3 2x4x1",
      "offCommand": "php /home/pi/tcp.php 192.168.8.3 2x4x0",
      "getStateCommand": "echo false",
      "interval": 0
    }
  ```
  - id               -- muss mit der "sid" des ESP's übereinstimmen
  - name             -- kann frei gewählt werden
  - onCommand        -- Einschaltbefehl "php <pfad/der/tcp.php> <ip-des-esp> <funktion>" die Kommandos findet ihr im Abschnitt "PHP Script"
  - offCommand       -- Ausschaltbefehl
  - getStateCommand  -- Befehl, der zur Schalterzustandaktualisierung verwendet wird. Dieser muss nicht verwendet werden da der Schalter seinen Zustand an Pimatic übermittelt
  - interval         -- Häufigkeit der Abfrage des Schalterzustandes in Millisekunden

![pimatic-switch](http://www.youscreen.de/gxmqrhwb10.jpg)

Funktioniert alles Korrekt, sollten sich im ESPlorer nach manueller Betätigung von "Switch1" folgende Debugzeilen abbilden

![pimatic-switch-debug](http://www.youscreen.de/skuzwqbs61.jpg)

... und sich der Schalterzustand in Pimatic entsprechend anpassen.

Bei Umlegen des schalters in Pimatic erscheinen fogende Debugzeilen (im ESPlorer sichtbar):

![pimatic-switch-debug2](http://www.youscreen.de/yovpflqp16.jpg)



## Manuelle Steuerung

Wollt ihr an der Platine einen Taster/Schalter anschliesen, bitte dafür **GND / GPIO12** für Relais 1/sid1 und  **GND / GPIO13** Relais 1/sid2 nutzen ( schaltet nach **GND** ) 

## Alternative Steuerungen


### PHP Script ([tcp.php](/tcp.php))

| Befehl  | Beschreibung | Antwort |
| ------------- | ------------- | ------------- |
| `php tcp.php 192.168.0.62 2x4x1` | Dieses Kommando schaltet **Relais 1** auf **AN** | |
| `php tcp.php 192.168.0.62 2x4x0` | Dieses Kommando schaltet **Relais 1** auf **AUS** | |
| `php tcp.php 192.168.0.62 2x5x1` | Dieses Kommando schaltet **Relais 2** auf **AN** | |
| `php tcp.php 192.168.0.62 2x5x0` | Dieses Kommando schaltet **Relais 2** auf **AUS** | |
| `php tcp.php 192.168.0.62 3x4` | Status vom **Relais 1** abfragen | `1/0` |
| `php tcp.php 192.168.0.62 3x5` | Status vom **Relais 2** abfragen | `1/0` |
| `php tcp.php 192.168.0.62 4x1`  | DHT22 Daten abfragen | Temp;Luftfeuchte |
| `php tcp.php 192.168.0.62 9x0` | Version abfragen | 0.3.2 |
| `php tcp.php 192.168.0.62 0x0` | ESP8266 neustarten | |
| `php tcp.php 192.168.0.62 update datei.lua` | Datei 'datei.lua' hochladen und ESP8266neu starten | | 

*192.168.0.62 ist im obigen Beispiel die IP Adresse des ESP8266*



## Sonstige Informationen

### Stromverbrauch

zwischen 0.6 und 1.2 Watt

### GPIO Mapping

| GPIO  | PIN | [IO index](https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#gpio-new-table--build-20141219-and-later) | Bemerkung |
| ------------- | ------------- | ------------- | ------------- |
| GPIO0 | 18 | 3 | Flashmodus (DS18D20 - ungetestet) |
| GPIO1 | 22 | 10 | UART TX|
| GPIO2 | 17 | 4 | Relais 1 / LED (blau) |
| GPIO3 | 21 | 9 | UART RX |
| GPIO4 | 19 | 2 | *frei* |
| GPIO5 | 20 | 1 | Relais 2 (oder DHT22) |
| GPIO9 | 11 | 11 | nur im DIO Modus nutzbar |
| GPIO10 | 12 | 12 | nur im DIO Modus nutzbar |
| GPIO12 | 6 | 6 | Schalter/Taster 1 |
| GPIO13 | 7 | 7 | Schalter/Taster 2 |
| GPIO14 | 5 | 5 | *frei* |
| GPIO15 | 16 | 8 | *frei* |
| GPIO16 | 4 | 0 | *frei* |

![Pinout](/pics/esp8266-pin.png?raw=true)

### Platinen Maße

- 48 mm breit (stark abgerundete Ecken)
- 48 mm lang
- 21 mm tief

### Neue Firmware flashen

Programmiermodus: **GPIO0** und **GND** mit einem Jumper verbinden, ESP8266 neu starten. Image mit [ESPTOOL](https://github.com/themadinventor/esptool) flashen:

#### MacOSX (im Beispiel wird NodeMCU "installiert")
````
python ./esptool.py --port=/dev/cu.SLAB_USBtoUART  write_flash  -fm=dio -fs=32m 0x00000 ../nodemcu-master-8-modules-2015-09-01-02-42-13-float.bin

Connecting...
Erasing flash...
Took 1.62s to erase flash block
Wrote 415744 bytes at 0x00000000 in 44.8 seconds (74.2 kbit/s)...

Leaving...
```

### ![Achtung](/pics/achtung-yellow.png?raw=true) 10A Erweiterung

Obwohl die Relais mit 10A belastet werden könnten, sind die Leiterbahnen zu den Schraubklemmen zu dünn und sind mit maximal 2A belastbar. Um die volle Belastbarkeit erreichen, muss man an der Unterseite der Platine die Leiterbahnen von den Relaisanschlüssen zur Schraubklemme mit tauglichen Drähten überbrücken/verstärken. (siehe [raspiprojekt.de](https://raspiprojekt.de/kaufen/shop/bausaetze/wifi-relais-zweifach.html))

![10A Erweiterung](/pics/esp8266-10a.png?raw=true)

