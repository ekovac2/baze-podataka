--Procedure

--1.Napisati proceduru za unos novog klijenta

CREATE OR REPLACE PROCEDURE KreirajKlijenta( iznos_racunap in klijenti.iznos_racuna%type,
                                             pogodnost_idp in klijenti.pogodnost_id%type,
                                             opklada_idp in klijenti.opklada_id%type,
                                             lice_idp in klijenti.lice_id%type) IS
BEGIN

  INSERT INTO klijenti
  VALUES (klijenti_id_sekv.nextval,iznos_racunap,pogodnost_idp,opklada_idp, lice_idp);
  COMMIT;
END;


--2. Napisati proceduru koja uklanja brise zaposlenika sa id prenesenim kao parametrom
--   samo ukoliko odjel u kojem radi vise nema sredstava

CREATE OR REPLACE PROCEDURE BrisiZaposlenika(zaposlenik IN zaposleni.zaposlenik_id%type) IS

  sredstva1 NUMBER:=0;
  postojilizaposlenik NUMBER:=0;
BEGIN
  SELECT Decode(zaposlenik_id,zaposlenik,1,0)
  INTO postojilizaposlenik
  FROM zaposleni;

  SELECT o.sredstva
  INTO sredstva1
  FROM odjeli o, zaposleni z
  WHERE o.odjel_id=z.odjel_id AND z.zaposlenik_id=zaposlenik;

  IF postojilizaposlenik=0 THEN
     Raise_Application_Error(-20501,'Ne postoji dati zaposlenik');
  ELSIF sredstva1=0 THEN
     DELETE FROM zaposleni
     WHERE zaposlenik_id=zaposlenik;
  ELSIF sredstva1<>0 THEN
      Raise_Application_Error(-20502,'Sredstva odjela nisu jednaka 0');
  END IF;
END;

--3. Kreirati proceduru za pohranjivanje iznosa opklade na racun klijenta
--   pri tome uracunati porez

CREATE OR REPLACE PROCEDURE IsplatiKlijenta (iznos IN NUMBER,
                                             id IN klijenti.klijent_id%type) IS

   iznos_uplate NUMBER:=0;

BEGIN
   SELECT iznos-d.porez*iznos
   INTO iznos_uplate
   FROM drzave d, lokacije l,
        odjeli oo, opklade o, klijenti k
   WHERE k.opklada_id=o.opklada_id AND d.drzava_id=l.drzava_id AND
         o.odjel_id=oo.odjel_id AND oo.lokacija_id=l.lokacija_id
         AND k.klijent_id=id;

  UPDATE klijenti
  SET iznos_racuna=iznos_racuna+iznos_uplate
  WHERE klijent_id=id;


END;

--4. Kreirati proceduru za promjenu pogodnosti klijenta

CREATE OR REPLACE PROCEDURE PromijeniPogodnost(nova_pogodnost in pogodnosti.tip_pogodnosti%TYPE,
                                               id IN klijenti.klijent_id%type) AS
  stara_pogodnost pogodnosti.tip_pogodnosti%type;
BEGIN
  SELECT p.tip_pogodnosti
  INTO stara_pogodnost
  FROM pogodnosti p, klijenti k
  WHERE p.pogodnost_id=k.pogodnost_id AND k.klijent_id=id;

  IF stara_pogodnost = nova_pogodnost THEN
    raise_application_error(-20503, 'Nova pogodnost je ista kao stara!');

  ELSE
  UPDATE pogodnosti p
  SET p.tip_pogodnosti = nova_pogodnost
  WHERE p.pogodnost_id=(SELECT p1.pogodnost_id
                        FROM pogodnosti p1, klijenti k
                        WHERE p1.pogodnost_id=k.pogodnost_id AND k.klijent_id=id);
  END IF;
END;

--5. Kreirati proceduru koja omogucava klijentu da promijeni strategiju
--   u opkladi poslanoj kao parametar

CREATE OR REPLACE PROCEDURE PromijeniStrategiju(nova_strategija in strategija.tip_strategije%TYPE,
                                                id IN klijenti.klijent_id%type) AS
  stara_strategija strategija.tip_strategije%TYPE;
BEGIN
  SELECT p.tip_strategije
  INTO stara_strategija
  FROM strategija p, klijenti k, opklade o, opklade_arhiva oa
  WHERE p.strategija_id=oa.strategija_id AND oa.opklada_id=o.opklada_id
        AND o.opklada_id=k.opklada_id AND k.klijent_id=id;

  IF stara_strategija = nova_strategija THEN
    raise_application_error(-20504, 'Nova strategija je ista kao stara!');

  ELSE
  UPDATE strategija p
  SET p.tip_strategije = nova_strategija
  WHERE p.strategija_id=(SELECT p1.strategija_id
                         FROM strategija p1, klijenti k, opklade o, opklade_arhiva oa
                         WHERE p1.strategija_id=oa.strategija_id AND oa.opklada_id=o.opklada_id
                         AND o.opklada_id=k.opklada_id AND k.klijent_id=id);
  END IF;
END;

--6.Kreirati proceduru za stavljanje datuma odrzavanje neke trke na null ukoliko je ona vec odrzana

CREATE OR REPLACE PROCEDURE PromijeniDatum AS

   datum DATE;

BEGIN
  SELECT t.datum_odrzavanja
  INTO datum
  FROM trke t;

  IF datum>sysdate THEN
    raise_application_error(-20505, 'Trka se tek treba odrzati');
  ELSE
  UPDATE trke t
  SET t.datum_odrzavanja=null
  WHERE t.datum_odrzavanja<SYSDATE;
  END IF;
END;

--7.Kreirati proceduru koja ce obracunavati platu zaposlenika zajedno sa dodatkom na platu
--  u zavisnosti od poreza drzave

CREATE OR REPLACE PROCEDURE ObracunajPlatu( plata out NUMBER,
                                            zaposlenik in zaposleni.zaposlenik_id%type) AS
BEGIN
  SELECT (plata+plata*dodatak_na_platu)*(1-d.porez)
  INTO plata
  FROM zaposleni z, odjeli o, lokacije l, drzave d
  WHERE z.zaposlenik_id=zaposlenik AND z.odjel_id=o.odjel_id AND
        o.lokacija_id=l.lokacija_id AND l.drzava_id=d.drzava_id;

END;


--8. Napisati proceduru koja æe prikazati maksimalan broj radnika u nekom odjelu


CREATE OR REPLACE PROCEDURE ProsjecanBrojRadnika(broj_radnika out NUMBER) AS
BEGIN
  SELECT Avg(z.zaposlenik_id)
  INTO broj_radnika
  FROM odjeli o, zaposleni z
  WHERE o.odjel_id=z.odjel_id
  GROUP BY o.naziv;

END;

--9. Napisati proceduru koja mijenja funkciju radnika

CREATE OR REPLACE PROCEDURE PromijeniFunkcijuRadnika( nova_funkcija IN funkcija_koju_obavlja.naziv%TYPE,
                                                      id IN zaposleni.zaposlenik_id%type) IS

  stara_funkcija funkcija_koju_obavlja.naziv%TYPE;

BEGIN
  SELECT f.naziv
  INTO stara_funkcija
  FROM funkcija_koju_obavlja f, zaposleni z
  WHERE z.funkcija_id=f.funkcija_id AND z.zaposlenik_id=id;

  IF stara_funkcija=nova_funkcija THEN
    raise_application_error(-20503, 'Nova funkcija je ista kao stara!');

  ELSE
  UPDATE funkcija_koju_obavlja f
  SET f.naziv=nova_funkcija
  WHERE f.funkcija_id =(SELECT f1.funkcija_id
                        FROM funkcija_koju_obavlja f1, zaposleni z
                        WHERE z.funkcija_id=f1.funkcija_id AND z.zaposlenik_id=id);
  END IF;
END;



--10. Napisati proceduru koja ce povecati iznos sredstava za 10% onoj poslovnici kojoj
--    se centralna nalazi u Meksiku

CREATE OR REPLACE PROCEDURE PovecajSredstvaUMeksiku AS
BEGIN
  UPDATE odjeli o
  SET o.sredstva=o.sredstva*1.1
  WHERE o.nadredjeni_odjel_id=(SELECT oo.odjel_id
                               FROM odjeli oo, lokacije l, drzave d
                               WHERE oo.lokacija_id=l.lokacija_id AND l.drzava_id =d.drzava_id
                                     AND d.naziv='Meksiko');
END;
