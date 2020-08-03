--Skripta

/*Skripta sluzi da ukoliko dodje do toga da neki odjel ostane bez sredstava,
 dostavlja upozorenje da je odjel ostao bez sredstava*/

CREATE OR REPLACE FUNCTION Upozorenje(poruka IN VARCHAR2)
RETURN VARCHAR2 IS
  povratna_poruka VARCHAR2(50):=poruka;
BEGIN
   RETURN(povratna_poruka);
END;

CREATE OR REPLACE PROCEDURE Upozorenje_Poruka(poruka IN VARCHAR2) IS
  povratna_poruka VARCHAR2(50):=poruka;
BEGIN
  SELECT Upozorenje(poruka)
  INTO povratna_poruka
  FROM odjeli;
END;


DECLARE
  stanje_racuna odjeli.sredstva%TYPE;

  CURSOR odjeli_i is
  SELECT odjel_id
  FROM odjeli;

BEGIN
  FOR trenutni_odjel IN odjeli_i LOOP

  SELECT o.sredstva
  INTO stanje_racuna
  FROM odjeli o
  WHERE o.odjel_id=trenutni_odjel.odjel_id;

  IF stanje_racuna<=0 THEN
      Upozorenje_Poruka('Odjel vise nema sredstava');
  END IF;
  END LOOP;
END;



