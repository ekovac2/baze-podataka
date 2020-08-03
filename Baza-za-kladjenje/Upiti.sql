/*10 jednostavnih upita*/

--1. Napisati upit koji æe vratiti osnovne podatke o zaposlenicima i odjel u kojem rade

SELECT l.ime||' '||l.prezime "Ime i prezime", l.spol "Spol",l.email "Email",
       z.plata + z.plata*Nvl(z.dodatak_na_platu,0) "Plata(Uracunat dodatak)",
       o.naziv "Odjel", o.sredstva "Zalihe odjela", o2.odjel_id "Odgovara odjelu: "
FROM lice l, zaposleni z, odjeli o, odjeli o2
WHERE l.lice_id=z.lice_id AND z.odjel_id=o.odjel_id AND o.nadredjeni_odjel_id=o2.odjel_id;


--2. Napisati upit koji prikazuje sve sifre opklada, te datum opklade koje su se odigrale u odjelu locoranom u Grckoj

SELECT o.opklada_id "Sifra", o.datum_opklade "Datum kladjenja"
FROM opklade o, odjeli od, lokacije l, drzave d
WHERE o.odjel_id=od.odjel_id AND od.lokacija_id=l.lokacija_id AND l.drzava_id=d.drzava_id
      AND d.naziv='Grcka';

--3. Napisati upit koji ce prikazati sve trenutne igrace i njihove timove

SELECT s.naziv, tim.naziv
FROM sport_lica s "Igrac", sport_lica tim "Tim"
WHERE s.tim_id=tim.sport_lica_id;

--4. Napisati upit koji æe prikazati sve muske klijente koji imaju bilo kakvu pogodnost

SELECT l.ime||' '||l.prezime "Ime i prezime", p.tip_pogodnosti "Tip pogodnosti"
FROM lice l, klijenti k, pogodnosti p
WHERE l.lice_id=k.lice_id AND k.pogodnost_id=p.pogodnost_id AND
      k.pogodnost_id<>NULL AND l.spol='musko';

--5. Napisati upit koji prikazuje sve drzave i njihov porez, sortirane po porezu

SELECT d.naziv "Drzava", d.porez
FROM drzave d
ORDER BY d.porez;

--6. Napisati upit koji æe prikazati sifre svih klijenata koji su se kladili da ce FC Barcelona igrati nerijeseno,
--   te datum kada su se kladili

SELECT k.klijent_id "Sifra klijenta", o.datum_opklade "Datum opklade"
FROM klijenti k, opklade o, opklade_arhiva oa, sport_lica sl, sport s
WHERE k.opklada_id=o.opklada_id AND oa.opklada_id=o.opklada_id AND oa.sport_lica_id=sl.sport_lica_id AND sl.tip_sporta_id=s.sport_id
      AND sl.naziv='Barcelona' AND s.naziv='Nogomet';


--7. Prikazati ime i prezime klijenta koji su odigrali listic na danasnji datum

SELECT l.ime||' '||l.prezime "Ime i prezime"
FROM lice l, klijenti k,opklade o
WHERE l.lice_id=k.lice_id AND k.opklada_id=o.opklada_id AND
      o.datum_opklade=SYSDATE;

--8. Ispisati sve zaposlene i platu, onih koji rade u odjelu 8 i obavljaju ulogu zastitara

SELECT l.ime||' '||l.prezime "Ime i prezime", z.plata + z.plata*Nvl(z.dodatak_na_platu,0) "Plata(Uracunat dodatak)"
FROM lice l, zaposleni z, funkcija_koju_obavlja f
WHERE l.lice_id=z.lice_id AND f.funkcija_id=z.funkcija_id AND f.naziv='Zastitar' AND z.odjel_id=8;

--9. Izlistati sve trke koje su se odrzale u 2017.godini i koliko je uèesnika bilo

SELECT t.naziv, t.broj_ucesnika
FROM trke t
WHERE To_Number(To_Char(t.datum_odrzavanja,'yyyy')) = 2017;

--10. Napisati upit koji æe prikazati sve trke koje su se odrzale u Sarajevu

SELECT t.naziv "Utrka"
FROM trke t, opklade_arhiva oa, opklade opk, odjeli o, lokacije l
WHERE l.grad='Sarajevo' AND o.lokacija_id=l.lokacija_id AND o.odjel_id=opk.odjel_id AND
      opk.opklada_id=oa.opklada_id AND oa.trka_id=t.trka_id;

/*5 upita sa grupnim funkcijama(2 sa having)*/

--1.Napisati upit koji æe prikazati prosjecan broj radnika po odjelima

SELECT o.naziv "Odjel",Avg(z.zaposlenik_id) "Prosjecan broj radnika"
FROM odjeli o, zaposleni z
WHERE o.odjel_id=z.odjel_id
GROUP BY o.naziv;

--2. Napisati upit koji æe prikazati koliko puta su se klijenti kladili na nogomet u toku dana

SELECT l.ime||' '||l.prezime "Ime i prezime", Count(o.opklada_id) "Broj opklada po klijentu"
FROM lice l, klijenti k,opklade o, opklade_arhiva oa, sport_lica sl, sport s
WHERE l.lice_id=k.lice_id AND k.opklada_id=o.opklada_id
      AND oa.opklada_id=o.opklada_id AND oa.sport_lica_id=sl.sport_lica_id AND sl.tip_sporta_id=s.sport_id
      AND o.datum_opklade=SYSDATE AND s.naziv='Nogomet'
GROUP BY l.ime||' '||l.prezime;

--3. Napisati upit koji æe prikazati drzave u kojoj imaju najmanje 3 poslovnice

SELECT d.naziv "Drzava"
FROM drzave d, lokacije l, odjeli o
WHERE d.drzava_id=l.drzava_id AND l.lokacija_id=o.lokacija_id
GROUP BY d.naziv
HAVING Count(o.odjel_id)>=3;

--4. Napisati upit koji æe prikazati broj opklada u 2017., te 2018.
--   godine, te ukupan broj opklada u ovim godinama.
SELECT Decode(Sum(Decode(To_Char(o.datum_opklade,'yyyy'),'2017',1,0)), NULL,0,Sum(Decode(To_Char(o.datum_opklade,'yyyy'),'2017',1,0))) "2017",
       Decode(Sum(Decode(To_Char(o.datum_opklade,'yyyy'),'2018',1,0)), NULL, 0,Sum(Decode(To_Char(o.datum_opklade,'yyyy'),'2018',1,0))) "2018",
       Decode(Sum(Decode(To_Char(o.datum_opklade,'yyyy'),'2017',1,'2018',1,0)),NULL,0,Sum(Decode(To_Char(o.datum_opklade,'yyyy'),'2017',1,'2018',1,0))) "Broj klijenata"
FROM opklade o;

--5. Napisati upit koji æe ispisati zaposlenika sa maksimalnom platom ali samo ukoliko je ona veæa od 2000

SELECT l.ime||' '||l.prezime "Ime i prezime"
FROM lice l, zaposleni z, odjeli o
WHERE l.lice_id=z.lice_id AND z.odjel_id=o.odjel_id
GROUP BY l.ime||' '||l.prezime
HAVING Max(z.plata)>2000;

/*5 upita sa podupitima*/

--1.Ispisati sve klijente kod kojih je tip pogodnosti jednak kao kod klijenta sa id=4

SELECT l.ime||' '||l.prezime "Ime i prezime", p.tip_pogodnosti "Tip pogodnosti"
FROM lice l, klijenti k, pogodnosti p
WHERE l.lice_id=k.lice_id AND k.pogodnost_id=p.pogodnost_id AND
      p.tip_pogodnosti = (SELECT p2.tip_pogodnosti
                          FROM pogodnosti p2, klijenti k
                          WHERE p2.pogodnost_id=k.pogodnost_id AND k.klijent_id=4);


--2.Napisati upit koji æe prikazati sve sportove koji se nalaze u bilo kojoj ligi ciji naziv sadrzi slovo B
--i broj ucesnika joj je veci od ili jednak 6

SELECT s.naziv "Sport"
FROM sport s, liga l
WHERE s.liga_id=l.liga_id AND l.liga_id=(SELECT l1.liga_id
                                         FROM liga l1
                                         WHERE Upper(l1.naziv) LIKE '%B%' AND l1.broj_ucesnika>=6);

--3.Napisati upit koji æe prikazati sve podatke o poslovnicama kojima je nadredjena poslovnica locirana u Bosni i Hercegovini

SELECT o.odjel_id "Sifra", o.naziv "Odjel", o.sredstva "Sredstva"
FROM odjeli o
WHERE o.nadredjeni_odjel_id=(SELECT oo.odjel_id
                             FROM odjeli oo, lokacije l, drzave d
                             WHERE oo.lokacija_id=l.lokacija_id AND l.drzava_id=d.drzava_id
                                   AND d.naziv='Bosna i Hercegovina');

--4. Prikazati klijente ciji je iznos racuna veci od prosjecnog iznosa racuna
--   svih klijenata koji su odigrali listic u poslovnici sa IDem 3

SELECT l.ime||' '||l.prezime "Ime i prezime"
FROM lice l, klijenti k,opklade o
WHERE l.lice_id=k.lice_id AND k.opklada_id=o.opklada_id AND
      k.iznos_racuna>(SELECT Avg(k1.iznos_racuna)
                      FROM klijenti k1, opklade oo
                      WHERE k1.opklada_id=oo.opklada_id AND oo.odjel_id=3 AND oo.opklada_id<>null);

--5. Napisati upit koji vraæa sve one poslovnice kod kojih su sredstva veca
--   od odjela sa maksimalnim sredstvima ali kad se uz sredstva uracuna porez

SELECT o.naziv
FROM odjeli o
WHERE o.sredstva>(SELECT Max(oo.sredstva)*(1-d.porez)
                  FROM odjeli oo, lokacije l, drzave d
                  WHERE oo.lokacija_id=l.lokacija_id AND l.drzava_id=d.drzava_id
                  GROUP BY d.porez);

/*5 upita sa vise podupita*/

--1.Prikazati klijente ciji je iznos racuna veci od iznosa racuna
--  onih klijenata koji su odigrali vise listica  na nerijeseno
--  od prosjecnog broja odigranih listica po klijentu.

SELECT l.ime||' '||l.prezime "Ime i prezime"
FROM lice l, klijenti k
WHERE l.lice_id=k.lice_id
      AND k.iznos_racuna>(SELECT k1.iznos_racuna
                          FROM klijenti k1, opklade o, strategija s, opklade_arhiva oa
                          WHERE k1.opklada_id=o.opklada_id AND o.opklada_id=oa.opklada_id
                                AND oa.strategija_id=s.strategija_id AND s.strategija_id='Nerijeseno'
                          GROUP BY k1.iznos_racuna
                          HAVING Count(o.opklada_id)>(SELECT Avg(oo.opklada_id)
                                                      FROM opklade oo, klijenti k
                                                      WHERE oo.opklada_id=k.opklada_id
                                                      GROUP BY k.klijent_id));


--2.Izlistati sifre opklada za timove koji imaju vise od 17 igraca

SELECT oa.opklada_id "Sifra opklade"
FROM opklade_arhiva oa, sport_lica sl
WHERE oa.sport_lica_id=sl.sport_lica_id
      AND sl.sport_lica_id=(SELECT sl1.tim_id
                            FROM sport_lica sl1
                            WHERE 17<=(SELECT Count(sl1.sport_lica_id)
                                       FROM sport_lica sl2
                                       WHERE sl2.tim_id=sl.sport_lica_id));


--3.Napisaiti upit koji æe azurirati tabelu zaposlenih tako da za svakog zaposlenog koji radi u poslovnici
--  kojem se nadredjena poslovnica nalazi u Spaniji poveca dodatak na platu za 2% od sredstava u toj poslovnici

UPDATE TABLE zaposlenici z
SET z.dodatak=(SELECT o.sredstva*0.02
               FROM odjeli o
               WHERE o.odjel_id=z.odjel_id
                     AND o.nadredjeni_odjel=(SELECT nad.odjel_id
                                             FROM odjeli nad, lokacije l, drzave d
                                             WHERE nad.lokacija_id=l.lokacija_id AND
                                                   l.lokacija_id=d.drzava_id AND d.naziv='Spanija'));

--4. Napisati upit koji æe prikazati sve zaposlene koji rade u odjelima kojima su presusila sredstva i koji se nalaze u
--   drzavi koja ima porez veci od prosjecnog poreza svih drzava

SELECT l.ime||' '||l.prezime "Ime i prezime"
FROM lice l, zaposleni z
WHERE l.lice_id=z.lice_id AND
      z.odjel_id= (SELECT o.odjel_id
                  FROM odjeli o, lokacije l, drzave d
                  WHERE o.sredstva=0 AND o.lokacija_id=l.lokacija_id AND
                        l.lokacija_id=d.drzava_id  AND d.porez>(SELECT Avg(d1.porez)
                                                                FROM drzave d1));


--5. Prikazati sve klijente koji su se vise od 2 puta kladili na igraca koji u timu ima
--   najveci broj igraca u odnosu na sve ostale timove

SELECT l.ime||' '||l.prezime "Ime i prezime"
FROM lice l, klijenti k
WHERE l.lice_id=k.lice_id AND
      2>=(SELECT Count(o.opklada_id)
          FROM opklade o, opklade_arhiva oa, sport_lica sl
          WHERE o.opklada_id=oa.opklada_id AND oa.sport_lica_id=sl.sport_lica_id
                AND sl.tim_id=(SELECT sl2.sport_lica_id
                               FROM sport_lica sl2
                               WHERE (SELECT Count(sl3.sport_lica_id)
                                      FROM sport_lica sl3
                                      WHERE sl3.tim_id=sl2.sport_lica_id) > (SELECT Max(Count(sl3.sport_lica_id))
                                                                             FROM sport_lica sl3, sport_lica sl4
                                                                             WHERE sl3.tim_id=sl4.sport_lica_id
                                                                             GROUP BY sl3.sport_lica_id)));




/*2 upita sa subtotalima*/

--1.Modifikovati 5. zadatak pri koristenju grupnih fja da se prikazu dodatni redovi sa subtotalima

SELECT l.ime||' '||l.prezime "Ime i prezime"
FROM lice l, zaposleni z, odjeli o
WHERE l.lice_id=z.lice_id AND z.odjel_id=o.odjel_id
GROUP BY rollup(l.ime||' '||l.prezime)
HAVING Max(z.plata)>2000;

--2.Napisati upit koji vraæa sve one poslovnice kod kojih su sredstva manja
--  od odjela sa minimalni sredstvima grupisanim po porezu, prikazati i dodatne redove sa subtotalima

SELECT o.naziv
FROM odjeli o
WHERE o.sredstva<(SELECT Min(oo.sredstva)
                  FROM odjeli oo, lokacije l, drzave d
                  WHERE oo.lokacija_id=l.lokacija_id AND l.drzava_id=d.drzava_id
                  GROUP BY d.porez)
GROUP BY rollup(o.naziv);

/*2 upita sa top N analizom*/
--1. Napisati upit koji æe prikazati top 5 sportova na koje su se
--   klijenti sa iznosom racuna manjim od 1200 kladili

SELECT s.naziv
FROM sport s
WHERE s.sport_id=(SELECT *
                  FROM (SELECT so.sport_id
                        FROM sport so, sport_lica sl,
                        opklade_arhiva oa, opklade o, klijenti k
                        WHERE so.sport_id=sl.tip_sporta_id AND sl.sport_lica_id=oa.sport_lica_id
                        AND o.opklada_id=k.opklada_id AND k.iznos_racuna<1200
                        GROUP BY so.sport_id
                        ORDER BY Count(o.opklada_id))
                  WHERE ROWNUM<=5);

--2.Prikaza top 3 klijenta koji su izvrsili najvise opklada u toku danasnjeg dana

SELECT l.ime||' '||l.prezime "Ime i prezime"
FROM lice l, klijenti k
WHERE l.lice_id=k.lice_id
      AND k.klijent_id=(SELECT *
                        FROM (SELECT k1.klijent_id
                              FROM klijenti k1, opklade o
                              WHERE k1.opklada_id=o.opklada_id AND o.opklada_id<>NULL
                                    AND o.datum_opklade=sysdate
                              GROUP BY k1.klijent_id
                              ORDER BY Count(o.opklada_id))
                         WHERE ROWNUM<=3);



/*1 sa union, set*/

--1. Napisati upit koji ce prikazati klijenata cije prezime pocinje sa M a imaju iznos racuna veci od 300,
-- i klijenate cije ime pocinje sa D a a imaju iznos racuna manji od 1000

SELECT l.ime||' '||l.prezime "Ime i prezime"
FROM lice l, klijenti k
WHERE l.lice_id=k.lice_id AND Upper(l.prezime) like 'M%' and
      k.iznos_racuna > 300
UNION
SELECT l.ime||' '||l.prezime
FROM lice l, klijenti k
WHERE l.lice_id=k.lice_id AND Upper(l.ime) like 'D%' and
      k.iznos_racuna < 1000;

