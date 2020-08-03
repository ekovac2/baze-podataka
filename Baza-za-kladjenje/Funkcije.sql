--Funkcije

--1.Funkcija koja provjerava da li je dati odjel ostao bez sredstava,
--  ako jeste vraca 1, u suprotnom vraca 0

CREATE OR REPLACE FUNCTION SredstvaOdjela(odjel_id in odjeli.odjel_id%TYPE)
RETURN NUMBER IS
    propao NUMBER:=1;
BEGIN
  SELECT Decode(o.sredstva,0,0,1)
  INTO propao
  FROM odjeli o
  WHERE o.odjel_id=odjel_id;

  RETURN(propao);
END;

--2. Kreirati funkciju koja ce da vrati koliko klijenata je odigralo listic na danasnji dan

CREATE OR REPLACE FUNCTION BrojKladjenjaUDanu
RETURN NUMBER IS
    broj NUMBER:=0;

BEGIN
SELECT count(k.klijent_id)
INTO broj
FROM klijenti k,opklade o
WHERE k.opklada_id=o.opklada_id AND
      o.datum_opklade=SYSDATE AND
      o.opklada_id<>NULL;

  RETURN(broj);
END;


--3. Napraviti funkciju koja vraca broj zaposlenih koji rade u glavnoj centrali

CREATE OR REPLACE FUNCTION BrojZaposlenihCentrala
RETURN NUMBER IS
    brojZaposlenih NUMBER:=0;

BEGIN
SELECT count(z.zaposlenik_id)
INTO brojZaposlenih
FROM zaposleni z, odjeli o, lokacije l, drzave d,odjeli nadredjeni, odjeli centrala
WHERE d.naziv='Meksiko' AND d.drzava_id=l.drzava_id AND
      l.lokacija_id=centrala.lokacija_id AND
      z.odjel_id=o.odjel_id AND
      nadredjeni.odjel_id=o.nadredjeni_odjel_id AND
      nadredjeni.nadredjeni_odjel_id=centrala.odjel_id;

  RETURN(brojZaposlenih);
END;

--4.Napisati funkciju koja ce vratiti klijenta sa najvise kladjenja u toku dana u nekom odjelu

CREATE OR REPLACE FUNCTION NajviseKladjenjaUTokuDana(odjeli_id in odjeli.odjel_id%TYPE)
RETURN NUMBER IS
    broj NUMBER:=0;

BEGIN
SELECT count(oa.opklada_id)
INTO broj
FROM klijenti k,opklade o, opklade_arhiva oa, odjeli oo
WHERE k.opklada_id=o.opklada_id AND oa.opklada_id=o.opklada_id AND
      o.odjel_id=oo.odjel_id AND oo.odjel_id=odjeli_id AND
      o.datum_opklade=SYSDATE AND
      o.opklada_id<>NULL
GROUP BY o.odjel_id;

  RETURN(broj);
END;


--5.Napisati funkciju koja prima iznos dobitka, i id opklade a
--  vraca koliko ce novca biti isplaceno u odnosu na porez drzave

CREATE OR REPLACE FUNCTION Isplata(iznos NUMBER, odjeli_id in odjeli.odjel_id%TYPE)
RETURN NUMBER IS
    dobitak NUMBER:=0;
BEGIN
SELECT iznos-d.porez*iznos
INTO dobitak
FROM opklade o,odjeli oo, lokacije l, drzave d
WHERE o.odjel_id=oo.odjel_id AND oo.lokacija_id=l.lokacija_id
      AND l.drzava_id=d.drzava_id AND o.odjel_id=odjeli_id
GROUP BY d.drzava_id;

  RETURN(dobitak);
END;

--6. Napisati funkciju koja vraca sport na koji se izvrsilo najvise opklada
--   u drzavi proslijedjenoj kao parametar

CREATE OR REPLACE FUNCTION KladjenjeSport(nazivi in drzave.drzava_id%TYPE)
RETURN VARCHAR2 IS
    sport_ime VARCHAR2(50);
BEGIN
SELECT ss.naziv
INTO sport_ime
FROM sport ss
WHERE ss.sport_id=(SELECT *
                   FROM (SELECT s.sport_id
                         FROM opklade o,odjeli oo, lokacije l,drzave d,
                              opklade_arhiva oa, sport_lica sl, sport s
                         WHERE d.naziv=nazivi AND o.odjel_id=oo.odjel_id AND
                               oo.lokacija_id=l.lokacija_id AND l.drzava_id=d.drzava_id AND
                               o.opklada_id=oa.opklada_id AND oa.sport_lica_id=sl.sport_lica_id AND
                               sl.tip_sporta_id=s.sport_id
                          GROUP BY s.sport_id
                          ORDER BY Count(oa.opklada_id))
                    WHERE ROWNUM<=1);
  RETURN(sport_ime);
END;

--7. Napisati funkciju koja ce vratiti koliko ima drzava u kojoj imaju najvise 4 poslovnice

CREATE OR REPLACE FUNCTION DrzaveSa4Poslovnice
RETURN VARCHAR2 IS
    broj_drzava VARCHAR2(50);
BEGIN
SELECT Count(DISTINCT d.naziv)
INTO broj_drzava
FROM drzave d, lokacije l, odjeli o
WHERE d.drzava_id=l.drzava_id AND l.lokacija_id=o.lokacija_id
GROUP BY d.naziv
HAVING Count(o.odjel_id)<=4;
  RETURN(broj_drzava);
END;

--8. Napisati funkciju koja vraca 1 ako u ligi La Liga unesen FC Real Madrid, u
--   suprotnom vraca 0

CREATE OR REPLACE FUNCTION LaLiga
RETURN NUMBER IS
     broj NUMBER:=0;
BEGIN
SELECT Decode(sl.naziv,'Real Madrid',1,0)
INTO broj
FROM sport_lica sl, sport ss, liga l
WHERE sl.tip_sporta_id=ss.sport_id AND ss.naziv='Nogomet' AND
      ss.liga_id=l.liga_id AND l.naziv='La Liga';
  RETURN(broj);
END;

--9.Napisati funkciju koja vraca id tima koji ima manje od 15 igraca


CREATE OR REPLACE FUNCTION TimSaManjeOd15Igraca
RETURN sport_lica.sport_lica_id%type IS
     id sport_lica.sport_lica_id%type;
BEGIN
SELECT sl.sport_lica_id
INTO id
FROM sport_lica sl
WHERE sl.sport_lica_id=(SELECT sl1.tim_id
                        FROM sport_lica sl1
                        WHERE 17<=(SELECT Count(sl1.sport_lica_id)
                                   FROM sport_lica sl2
                                   WHERE sl2.tim_id=sl.sport_lica_id));
  RETURN(id);
END;



--10. Napisati funckiju koja vraca broj odjela kod kojih su sredstva veca
--    od prosjenog broja sredstava svih odjela ne racunajuci taj odjel


CREATE OR REPLACE FUNCTION OdjeliSredstva
RETURN NUMBER IS
     broj NUMBER:=0;
BEGIN
SELECT Count(distinct o.naziv)
INTO broj
FROM odjeli o
WHERE o.sredstva>(SELECT avg(oo.sredstva)
                  FROM odjeli oo
                  WHERE oo.odjel_id<>o.odjel_id);
  RETURN(broj);
END;



