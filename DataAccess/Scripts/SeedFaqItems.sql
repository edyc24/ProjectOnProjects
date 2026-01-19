-- Script pentru popularea FAQ cache cu întrebări frecvente
-- Rulează acest script în baza de date moneyshop după ce tabelele sunt create

USE [moneyshop];
GO

-- Șterge FAQ-urile existente (opțional, pentru re-seed)
-- DELETE FROM FaqItems;

-- Inserează FAQ-uri
INSERT INTO FaqItems (Question, Answer, AliasesJson, TagsJson, Priority, Enabled, CreatedAt, UpdatedAt)
VALUES
(
    'ce este gradul de indatorare',
    'Gradul de indatorare (DTI) arata cat din venitul tau lunar poate fi alocat ratelor totale (credite, leasing, IFN). In practica, creditorii folosesc praguri diferite in functie de venit, stabilitate si politici interne. Daca vrei, spune-mi venitul net aproximativ si obligatiile lunare totale ca sa iti explic cum se interpreteaza. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["ce inseamna gradul de indatorare", "ce inseamna dti", "grad indatorare 40 50"]',
    '["GRAD_INDATORARE"]',
    10,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'ce este ircc',
    'IRCC este un indice de referinta folosit in Romania pentru anumite credite cu dobanda variabila. In general, dobanda variabila se poate exprima ca: indice (ex. IRCC) + marja. Valoarea finala depinde de conditiile concrete si de politicile creditorului. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["ircc ce inseamna", "cum se calculeaza ircc", "indice ircc"]',
    '["DOBANZI"]',
    9,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'care e diferenta intre dobanda fixa si variabila',
    'Dobanda fixa ramane aceeasi pe perioada fixa stabilita (ex. 3 ani), iar dobanda variabila se modifica in timp in functie de un indice (de exemplu IRCC) plus marja. Dobanda fixa ofera stabilitate, variabila poate scadea sau creste in timp. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["dobanda fixa vs variabila", "ce inseamna dobanda fixa", "ce inseamna dobanda variabila"]',
    '["DOBANZI"]',
    9,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'ce avans imi trebuie la credit ipotecar',
    'Avansul la ipotecar depinde de situatie (de exemplu daca este prima locuinta pe numele tau, daca ai mai avut o locuinta, si de tipul venitului). In general, cu cat avansul este mai mare, cu atat finantarea este mai usoara. Spune-mi te rog: ai mai avut o locuinta pe numele tau si venitul este din Romania sau din strainatate? Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["avans credit ipotecar cat", "ltv ce inseamna", "avans prima locuinta"]',
    '["IPOTECAR_LTV_AVANS"]',
    10,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'am avut restante mai pot lua credit',
    'Restantele pot influenta eligibilitatea, in special daca sunt recente, repetate sau de durata mare. Conteaza cate intarzieri au fost, cate zile aproximativ (30/60/90+), daca sunt active sau inchise si cum arata istoricul recent. Pot sa iti explic pe criterii generale daca imi spui doar aceste informatii (fara date personale). Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["intarzieri la plata mai pot face credit", "restante 30 zile", "restante 60 zile"]',
    '["RESTANTE"]',
    10,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'am credite ifn ma afecteaza',
    'Creditele nebancare (IFN) pot afecta eligibilitatea prin cresterea obligatiilor lunare si prin istoricul de credit. Important este totalul ratelor, stabilitatea veniturilor si comportamentul de plata. O abordare frecventa este reducerea obligatiilor si stabilizarea bugetului inainte de un credit nou. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["ifn imi scade sansele", "nebancare ma incurca", "am multe ifn"]',
    '["IFN"]',
    9,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'ce acte imi trebuie pentru credit de nevoi personale',
    'In general, pentru un credit de nevoi personale se cer: act identitate, dovada venitului (in functie de tipul venitului), si uneori extras de cont. Lista exacta poate varia. Evita sa trimiti documente in chat; foloseste doar zonele securizate ale aplicatiei daca exista. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["acte nevoi personale", "documente pentru credit de consum"]',
    '["DOCUMENTE"]',
    8,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'ce acte imi trebuie pentru credit ipotecar',
    'Pentru ipotecar, pe langa actele de identitate si dovada venitului, de regula apar documente ale imobilului (acte proprietate, cadastru/intabulare, evaluare) si documente de asigurare. Lista variaza in functie de caz. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["documente ipotecar", "acte casa ipotecar"]',
    '["DOCUMENTE"]',
    9,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'cand merita refinantarea',
    'Refinantarea poate merita daca obtii o rata lunara mai mica, o dobanda totala mai buna, sau daca vrei sa consolidezi mai multe obligatii intr-una singura. Ia in calcul si costurile (evaluare/notar/taxe/comisioane). Daca imi spui aproximativ suma ramasa, rata actuala si perioada, iti explic criteriile generale. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["merita sa refinantez", "refinantare rata mai mica"]',
    '["REFINANTARE"]',
    8,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'ce inseamna scor fico',
    'Scorul (de tip FICO) este un indicator al comportamentului de creditare bazat pe istoricul tau (plati la timp, intarzieri, utilizare, vechime, numar de conturi). Nu este singurul criteriu, dar poate influenta decizia si conditiile. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["fico ce este", "scor credit ce inseamna"]',
    '["BIR0U_CREDIT"]',
    8,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'de ce se face media venitului pe mai multe luni',
    'Media venitului pe mai multe luni ajuta la evaluarea stabilitatii. Unele situatii (bonusuri, fluctuatii) pot distorsiona o singura luna. De aceea, o medie (de exemplu pe 3-6 luni) ofera o imagine mai realista. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["media venit anaf 6 luni", "de ce nu iau ultima luna"]',
    '["ANAF_VENIT"]',
    7,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'calculatorul arata mai putin decat ma asteptam de ce',
    'Suma poate iesi mai mica din cauza a 3 lucruri principale: (1) venitul luat in calcul (media si tipul venitului), (2) obligatiile lunare existente (rate/IFN/leasing), (3) regulile de incadrare (grad de indatorare, perioada, avans la ipotecar). Daca imi spui venitul net aproximativ si obligatiile lunare totale, iti explic cum se interpreteaza. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["de ce imi iese suma mica", "de ce nu ma incadrez"]',
    '["CALCULATOR_REZULTAT"]',
    9,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'ce este consimtamantul pentru anaf',
    'Consimtamantul este folosit pentru a putea obtine si utiliza legal informatii despre venit in scopul evaluarii eligibilitatii, conform regulilor de protectie a datelor si proceselor aplicabile. In aplicatiile digitale, consimtamantul se acorda in mod explicit. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["de ce trebuie consimtamant anaf", "raport anaf consimtamant"]',
    '["ANAF_VENIT"]',
    7,
    1,
    GETUTCDATE(),
    GETUTCDATE()
),
(
    'ce costuri mai sunt la ipotecar pe langa rata',
    'La ipotecar pot aparea costuri precum evaluarea imobilului, notar, taxe, asigurari si uneori comisioane. Costurile exacte depind de caz. Daca vrei, iti explic lista tipica si ce influenteaza fiecare cost. Rezultatele sunt estimative; aprobarea finala apartine creditorului.',
    '["costuri ipotecar notar evaluare", "cat costa notarul"]',
    '["IPOTECAR_LTV_AVANS"]',
    7,
    1,
    GETUTCDATE(),
    GETUTCDATE()
);

PRINT 'FAQ items au fost inserate cu succes!';
GO

