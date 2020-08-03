CREATE TABLE Lice(lice_id INTEGER PRIMARY KEY NOT NULL,
                  ime VARCHAR2(20),
                  prezime VARCHAR2(20),
                  JMBG VARCHAR2(13),
                  email VARCHAR2(20),
                  spol VARCHAR2(10),
CONSTRAINT c_lice_spol_CK CHECK (spol IN ('zensko','musko')));



CREATE TABLE Zaposleni( zaposlenik_id INTEGER PRIMARY KEY NOT NULL,
                        plata NUMBER(20),
                        dodatak_na_platu  NUMBER(6),
                        datum_zaposlenja DATE,
                        funkcija_id INTEGER NOT NULL REFERENCES Funkcija_Koju_Obavlja(funkcija_id),
                        odjel_id INTEGER NOT NULL REFERENCES Odjeli(odjel_id),
                        lice_id INTEGER NOT NULL REFERENCES Lice(lice_id));

CREATE TABLE Funkcija_Koju_Obavlja(funkcija_id INTEGER PRIMARY KEY NOT NULL,
                                   naziv VARCHAR2(20));


CREATE TABLE Odjeli(odjel_id INTEGER PRIMARY KEY NOT NULL,
                    naziv NUMBER(20),
                    sredstva NUMBER(30),
                    nadredjeni_odjel_id INTEGER NOT NULL REFERENCES Odjeli(odjel_id),
                    lokacija_id INTEGER NOT NULL REFERENCES Lokacije(lokacija_id));

CREATE TABLE Lokacije(lokacija_id INTEGER PRIMARY KEY NOT NULL,
                      grad varchar2(50),
                      adresa VARCHAR2(50),
                      drzava_id INTEGER NOT NULL REFERENCES Drzave(drzava_id));

CREATE TABLE Drzave(drzava_id INTEGER PRIMARY KEY NOT NULL,
                    naziv varchar2(50),
                    porez NUMBER(7));


CREATE TABLE Klijenti(klijent_id INTEGER PRIMARY KEY NOT NULL,
                      iznos_racuna NUMBER(20),
                      pogodnost_id INTEGER REFERENCES Pogodnosti(pogodnost_id),
                      opklada_id INTEGER REFERENCES Opklade(opklada_id),
                      lice_id INTEGER NOT NULL REFERENCES Lice(lice_id));

CREATE TABLE Pogodnosti(pogodnost_id INTEGER PRIMARY KEY NOT NULL,
                        tip_pogodnosti VARCHAR2(20));

CREATE TABLE Strategija(strategija_id INTEGER PRIMARY KEY NOT NULL,
                        tip_strategije VARCHAR2(30),
CONSTRAINT c_strategija_tip_CK CHECK (tip_strategije IN ('pobjeda','poraz','nerijeseno')));

CREATE TABLE Opklade(opklada_id INTEGER PRIMARY KEY NOT NULL,
                     odjel_id INTEGER REFERENCES Odjeli(odjel_id),
                     datum_opklade DATE,
                     broj_listica INTEGER);

CREATE TABLE Opklade_arhiva(opklada_id INTEGER REFERENCES Opklade(opklada_id),
                            strategija_id INTEGER REFERENCES Strategija(strategija_id),
                            sport_lica_id INTEGER REFERENCES Sport_lica(sport_lica_id),
                            trka_id INTEGER REFERENCES Trke(trka_id));

CREATE TABLE Sport_lica(sport_lica_id INTEGER PRIMARY KEY NOT NULL,
                        naziv VARCHAR2(50),
                        tim_id INTEGER REFERENCES Sport_lica(sport_lica_id),
                        tip_sporta_id INTEGER REFERENCES Sport(sport_id));

CREATE TABLE Sport(sport_id INTEGER PRIMARY KEY NOT NULL,
                   naziv VARCHAR2(50),
                   liga_id INTEGER REFERENCES Liga(liga_id));

CREATE TABLE Liga(liga_id INTEGER PRIMARY KEY NOT NULL,
                  naziv VARCHAR2(50),
                  broj_ucesnika INTEGER,
                  bodovi INTEGER);

CREATE TABLE Trke(trka_id INTEGER PRIMARY KEY NOT NULL,
                  naziv VARCHAR2(50),
                  broj_ucesnika INTEGER,
                  datum_odrzavanja DATE);

CREATE TABLE Statistika(statistika_id INTEGER PRIMARY KEY NOT NULL,
                        sport_lica_id INTEGER REFERENCES Sport_lica(sport_lica_id),
                        trke_id INTEGER REFERENCES Trke(trka_id)
);

CREATE TABLE Statistika_arhiva(statistika_id INTEGER REFERENCES Statistika(statistika_id),
                               bodovi INTEGER,
                               tip VARCHAR2(20));
