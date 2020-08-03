--Trigeri

--1.Trigger za sredstva u odjelu koja ne smiju biti = 0

CREATE OR REPLACE TRIGGER OdjeliSredstvaTriger
BEFORE INSERT OR UPDATE ON odjeli
FOR EACH ROW
DECLARE
  sredstva_validacija number;
BEGIN

  SELECT Decode(o.sredstva, 0, 0, 1)
  INTO sredstva_validacija
  FROM odjeli o;

  IF sredstva_validacija = 0 THEN
    raise_application_error (-20507, 'Dati odjel nema vise dovoljno sredstava da bi funkcionisao!');
  END IF;
END;

--2. Triger za platu zaposlenika, ne smije biti < 0

CREATE OR REPLACE TRIGGER PlataZaposlenikaTriger
BEFORE INSERT OR UPDATE ON zaposlenici
FOR EACH ROW

BEGIN
  IF :new.plata < 0 THEN
    raise_application_error (-20510, 'Plata ne smije biti manja od 0');
  END IF;
END;

--3. triger ako se pokusaju unijeti nelegalna sredstva u odjele

CREATE OR REPLACE TRIGGER NelegalnaSredstvaTriger
BEFORE INSERT OR UPDATE ON odjeli
FOR EACH ROW
DECLARE
BEGIN
  IF :new.sredstva <= 0 THEN
    raise_application_error (-20511, 'Odjel ne moze imati sredstva manja od ili jednaka 0');
  END IF;
END;


--4. triger za provjeru da li je strategija ispravno unijeta

CREATE OR REPLACE TRIGGER StrategijaIspravnaTriger
BEFORE INSERT OR UPDATE ON strategija
FOR EACH ROW
DECLARE
BEGIN
  IF Lower(:new.tip_strategije) NOT IN ('pobjeda', 'poraz','nerijesen') THEN
    raise_application_error (-20512, 'Neispravan tip strategije');
  END IF;
END;


--5. Provjera da li je spol unesen ispravno

CREATE OR REPLACE TRIGGER IspravanSpol
BEFORE INSERT OR UPDATE ON lice
FOR EACH ROW
DECLARE
BEGIN
  IF Lower(:new.spol) NOT IN ('musko', 'zensko') THEN
    raise_application_error (-20513, 'Neispravan spol!');
  END IF;
END;


--6. Provjera da li je datum vrsenja opklade izvrsen prije danasnjeg dana

CREATE OR REPLACE TRIGGER IspravanDatumKladjenja
BEFORE INSERT OR UPDATE ON opklade
FOR EACH ROW
DECLARE
BEGIN
  IF :new.datum_opklade>sysdate THEN
    raise_application_error (-20513, 'Neisparan datum kladjenja!');
  END IF;
END;


--7. Provjera da li je datum odrzavanja utrke poslije danasnjeg dana

CREATE OR REPLACE TRIGGER IspravanDatumTrke
BEFORE INSERT OR UPDATE ON trke
FOR EACH ROW
DECLARE
BEGIN
  IF :new.datum_odrzavanja<sysdate THEN
    raise_application_error (-20513, 'Trka vec odrzana');
  END IF;
END;


--8. Napisati triger koji ce za nadredjenu poslovnicu, nadredjene poslovnice staviti onu koja se nalazi u meksiku

CREATE OR REPLACE TRIGGER NadredjenaPoslovnica
BEFORE INSERT OR UPDATE ON odjeli
FOR EACH ROW
DECLARE
BEGIN
  UPDATE odjeli o
  SET o.nadredjeni_odjel_id=(SELECT oo.odjel_id
                             FROM odjeli oo, lokacije l, drzave d
                             WHERE oo.lokacija_id=l.lokacija_id AND l.drzava_id=d.drzava_id
                                   AND d.naziv='Meksiko')
  WHERE o.odjel_id=(SELECT oo.nadredjeni_odjel_id
                    FROM odjeli oo);

END;


--9. Kreirati triger koji ce omoguciti automatsko dodjeljivanje id tabeli sport

CREATE OR REPLACE TRIGGER DodijeliIDSport
BEFORE INSERT OR UPDATE ON sport
FOR EACH ROW
DECLARE
BEGIN
  INSERT INTO sport
  VALUES (sport_id_sekv.nextval,:new.naziv,:new.liga_id);
END;



--10.Kreirati triger nad vašom tabelom trke koji se za promjenu datuma_odrzavanja trke
--   stari datum unijeti u novu tabelu trke_arhiva, koja ce sadrzavati pored tog datum
--   id zaposlenika koji je azurirao datum, te id trke

CREATE TABLE trke_arhiva(stari_datum DATE,
                         zaposlenik_id INTEGER,
                         trka_id INTEGER REFERENCES trke(trka_id));


CREATE OR REPLACE TRIGGER NadredjenaPoslovnicaTriger
BEFORE INSERT OR UPDATE ON trke
FOR EACH ROW
DECLARE
BEGIN
  INSERT INTO trke_arhiva
  SELECT :old.datum_odrzavanja, z.zaposlenik_id,:old.trka_id
  FROM trke t, opklade_arhiva oa, opklade o, odjeli oo, zaposleni z
  WHERE t.trka_id=oa.trka_id AND oa.opklada_id=o.opklada_id AND
        oo.odjel_id=z.odjel_id;
END;
