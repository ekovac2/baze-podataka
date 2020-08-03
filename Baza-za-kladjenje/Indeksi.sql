--Indeksi

CREATE INDEX lice_ime_i_prezime_indeks
ON lice(ime, prezime);

--indeks je kreiran zbog cinjenice da kada pretrazujemo podatke kako
--o klijentima tako i o zaposlenicima, uvijek pisemo ove dvije kolone skupa

CREATE INDEX drzave_drzave_naziv_indeks
ON Drzave(naziv);

--indeks kreiran iz razloga sto u upitima u where klauzi cesto pristupamo imenu drzave
--jer je nam je cesto za mnoge stvari bitno u kojoj se drzavi nalazi neki odjel, takodjer
--cesto koristena kolona u group by..

CREATE INDEX drzave_drzave_porez_indeks
ON Drzave(porez);

--Takodjer jedna od kolona kojoj se cesto pristupa u where klauzi zbog cinjenice da od poreza
--ovisi dobitak klijenta, pogodnosti koje moze dobiti i sl.

CREATE INDEX opklade_datum_opklade_indeks
ON Opklade(datum_opklade);

--Indeks kreiran zbog cinjenice da se kolona u koj se pristupa datumu cesto koristi
--u where klauzama koje se cesto naalze i u ugnijezdenim upitima

CREATE INDEX odjeli_sredstva_indeks
ON odjeli(sredstva);

--indeks kreiran jer se kolona sredstva cesto koristi u where klauzi
