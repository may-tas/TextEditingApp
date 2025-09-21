#!/bin/bash

echo "Adding all contributors..."

npx all-contributors add may-tas code,doc,maintenance,design
npx all-contributors add PearlGrell code
npx all-contributors add MannemSumanaSri code
npx all-contributors add Manar-Elhabbal7 code
npx all-contributors add Atomic-Shadow7002 code
npx all-contributors add Elwin-p code
npx all-contributors add preetidas60 code
npx all-contributors add AnanyaSingh456 code
npx all-contributors add DMounas code
npx all-contributors add debasmitaas code
npx all-contributors add GauriRocksies code
npx all-contributors add Rishi-1512 code
npx all-contributors add Rudraksha-git code
npx all-contributors add zxnb01 code
npx all-contributors add ishita051 code
npx all-contributors add pranayshl code

echo "Generating contributors table..."
npx all-contributors generate

echo "Done! Check your README.md for the contributors section."
