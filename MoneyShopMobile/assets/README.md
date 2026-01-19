# Assets Folder

Acest folder conține toate asset-urile pentru aplicația MoneyShop Mobile.

## Structură recomandată:

```
assets/
├── images/
│   ├── logo.png              # Logo principal MoneyShop
│   ├── logo-white.png        # Logo pentru fundal dark
│   └── partners/
│       ├── bcr.png
│       ├── bt.png
│       ├── brd.png
│       ├── ing.png
│       ├── unicredit.png
│       └── garanti.png
└── icons/
    └── (iconițe custom dacă e nevoie)
```

## Utilizare în cod:

```typescript
// Pentru logo
import logoImage from '../../assets/images/logo.png';

// Pentru parteneri
import bcrLogo from '../../assets/images/partners/bcr.png';
```

## Note:

- Folosește imagini PNG cu fundal transparent pentru logo-uri
- Dimensiuni recomandate:
  - Logo: 200x200px (sau mai mare pentru retina)
  - Logo-uri parteneri: 200x80px (sau proporțional)
- Optimizează imaginile înainte de adăugare (TinyPNG, etc.)

