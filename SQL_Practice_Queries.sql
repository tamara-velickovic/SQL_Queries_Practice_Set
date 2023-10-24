--*7. Prikazati imena svih upravnika cije idbr rukovodilaca je 5842 
--ali cija je plata ili strogo iznad ili strogo ispod 2400 
--a koji nisu u odeljenju ciji je broj 30 ili 40.


SELECT ime FROM radnik WHERE posao='upravnik' 
                       AND rukovodilac = 5842
                       AND (plata > 2400 OR plata < 2400)
                       AND broj_odeljenja NOT IN (30, 40);


--*11. Prikazati idbr onih koji se zovu 'Biljana' ili 'Strahinja', koji se ne zovu 'Amanda', 
--ciji broj rokuvodilaca je neki od brojeva 5555, 6666 ili 7777, 
--ali tako da im je premija strogo manja od 500 uz platu strogo vecu od 1000
-- ili tako da im je premija veca ili jednaka od 500 uz platu manju ili jednaku od 1000.

SELECT idbr FROM radnik
            WHERE (ime = 'Biljana' OR ime = 'Strahinja')
            AND ime != 'Amanda'
            AND rukovodilac IN (5555, 6666, 7777)
            AND ((premija < 500 AND plata > 1000) OR (premija >= 500 AND plata <= 1000));


--*13. Prikazati poslove za koje je potrebna VSS kvalifikacija (paziti dobro na rezultat ovog upita).

SELECT DISTINCT posao 
       FROM radnik 
       WHERE kvalifikacija= 'VSS';


--*18. Prikazati idbr radnika od najveceg ka najmanjem cije ime ima slovo 'c' na 2. mestu u imenu ili slovo 'v' na 3. mestu
-- ili  slovo 'o' na 4. mestu ili da ima sekvencu 'as' negde u imenu.

SELECT idbr, ime FROM radnik 
                 WHERE ime ILIKE '_c%' 
                 OR ime ILIKE '__v%' 
                 OR ime ILIKE '___o%' 
                 OR ime ILIKE '%as%'
                 ORDER BY idbr DESC ;

--*23.Za svaku funkciju, za svaki broj sati prikazati maksimalni broj projekta
--poredjane po  maksimalnom broju projekata silazno

SELECT  funkcija, broj_sati , MAX(broj_projekta) AS "max broj projekta" 
FROM ucesce 
GROUP BY funkcija, broj_sati
ORDER BY MAX(broj_projekta) DESC;

--*23. Za svaku funkciju, za svaki broj sati prikazati maksimalni broj sati 
--poredjano  maksimalnom broju projekata silazno


SELECT  funkcija, MAX(broj_sati) AS "max broj sati" 
FROM ucesce 
GROUP BY funkcija 
ORDER BY MAX(broj_projekta) DESC;


--*25. Prikazati najvecu premiju i najmanju platu za svaki posao, uzimajuci u obzir samo premije 
--i plate onih radnika koji imaju rukovodioca.


SELECT MAX(premija) AS max_premija, MIN(plata) AS min_plata, posao 
FROM radnik 
WHERE rukovodilac IS NOT null 
GROUP BY(posao) ;



--*26. Prikazati one poslove koji imaju strogo vise od 2 radnika.

SELECT posao 
FROM radnik  
GROUP BY posao 
HAVING COUNT(idbr)>2;



--*27. Prikazati kvalifikacije i njihove minimalne i maximalne plate uzimajuci u obzir samo plate vece od 1000
-- i zanemarujuci maksimalne plate manje od 2000

SELECT kvalifikacija, MIN(plata), MAX(plata) 
FROM radnik 
WHERE plata>1000
GROUP BY kvalifikacija
HAVING MAX(plata)>2000;


--KV x,x 
--VKV x,1200


--*29. Za svaki posao prikazati ono mesto na kome radi najvise radnika.

SELECT r.posao, o.mesto, COUNT(*) AS broj_radnika
FROM radnik AS r
JOIN odeljenje AS o ON r.broj_odeljenja = o.broj_odeljenja
GROUP BY r.posao, o.mesto
HAVING COUNT (*) = 
    (SELECT MAX(broj_radnika)
    FROM 
    (SELECT posao, broj_odeljenja, COUNT(*) AS broj_radnika
    FROM radnik
    GROUP BY posao, broj_odeljenja)
    AS prikaz
WHERE prikaz.posao = r.posao
)
ORDER BY posao;


--*31. Prikazati za svako odeljenje ime radnika koji ima najvise odradjenih broja sati a koji nije na projektu 'izvoz',
-- uzimajuci u obzir samo radnike kome je zadata neka (bilo kakva) premija.


SELECT r.ime, MAX(ukupno_sati) AS max_sati, r.broj_odeljenja
FROM ucesce AS u
JOIN(SELECT idbr, SUM(broj_sati) AS ukupno_sati
     FROM ucesce
     GROUP BY idbr)
     AS sum_sati_idbr ON u.idbr = sum_sati_idbr.idbr
JOIN radnik AS r ON u.idbr = r.idbr
JOIN projekat AS p ON u.broj_projekta = p.broj_projekta
WHERE p.imeproj != 'izvoz' AND (r.premija IS NOT NULL AND r.premija > 0)
GROUP BY r.ime, r.broj_odeljenja
ORDER BY broj_odeljenja;

--Marko radi uvoz, izvoz i plasman

--*32. Prikazati par razlicitih imena koji rade na istoj poziciji i zavrsavaju se na slovo 'o' 
--poredjanih leksikografski od najveceg ka najmanjem po prvom imenu 
--a leksikografski od najmanjeg ka najvecem po drugom imenu 


SELECT DISTINCT r1.ime AS "prvo ime", r2.ime AS "drugo ime"
FROM radnik AS r1
JOIN radnik AS r2 ON r1.posao = r2.posao
WHERE  r1.ime != r2.ime AND r1.ime ILIKE '%o' AND r2.ime ILIKE '%o'
ORDER BY "prvo ime" DESC, "drugo ime" ASC;



--dodatni zadatak, neobavezan: Prikazati par imena koji rade na istoj poziciji i zavrsavaju se na isto slovo
-- poredjanih leksikografski od najveceg ka najmanjem po prvom imenu a leksikografski od najmanjeg ka najvecem po drugom imenu 
--<- moracete da guglujete za ovo)


SELECT  r1.ime AS "prvo ime", r2.ime AS "drugo ime"
FROM radnik AS r1
JOIN radnik AS r2 ON r1.posao = r2.posao
WHERE r1.ime != r2.ime AND RIGHT(r1.ime, 1) = RIGHT(r2.ime, 1)
ORDER BY r1.ime DESC, r2.ime ASC;


--*33. Prikazati na kom mestu je odeljenje koje ima prosecnu platu medju odeljenjima, racunajuci prosek sa tacnoscu od dve decimale.
-- (paziti DOOOBROOO sta vam se ovde tacno trazi!) (Resenje: 'Banovo Brdo')

SELECT o.mesto
FROM odeljenje AS o
JOIN 
    (SELECT broj_odeljenja, AVG(plata) AS prosecna_plata
    FROM radnik
    GROUP BY broj_odeljenja)
    AS sve_pplate ON o.broj_odeljenja = sve_pplate.broj_odeljenja
WHERE ROUND(prosecna_plata, 2) =
(SELECT MAX(ROUND(prosecna_plata, 2))
 FROM 
(SELECT AVG(plata) AS prosecna_plata
 FROM radnik
 GROUP BY broj_odeljenja)
 AS prikaz);

