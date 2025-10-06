# Marktstammdatenregister herunterladen und in SQLite-Datenbank speichern
#
# Siehe 
# - https://github.com/OpenEnergyPlatform/open-MaStR

from open_mastr import Mastr
db = Mastr()
db.download()
