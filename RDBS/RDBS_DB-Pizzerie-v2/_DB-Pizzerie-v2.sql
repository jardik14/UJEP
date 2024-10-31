START TRANSACTION;

--
-- Databáze: Pizzerie-v2
--

CREATE DATABASE IF NOT EXISTS Pizzerie2 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci;

USE Pizzerie2;

-- --------------------------------------------------------

--
-- Struktura tabulky druhy_vyrobku
--

CREATE TABLE druhy_vyrobku (
  id_dru int PRIMARY KEY AUTO_INCREMENT,
  nazev char(15) NOT NULL
) ENGINE=InnoDB;

--
-- Vypisuji data pro tabulku druhy_vyrobku
--

INSERT INTO druhy_vyrobku (id_dru, nazev) VALUES
(1, 'salát'),
(2, 'pizza'),
(3, 'těstoviny'),
(4, 'kebab'),
(5, 'nealko'),
(6, 'pivo'),
(7, 'víno');

--
-- Struktura tabulky pozice
--

CREATE TABLE pozice (
  id_poz int(11) PRIMARY KEY AUTO_INCREMENT,
  nazev char(20) NOT NULL,
  plat mediumint(6) UNSIGNED NOT NULL,
  id_poz_nad INT
) ENGINE=InnoDB;

ALTER TABLE Pozice ADD CONSTRAINT fk_nadrizeny FOREIGN KEY (id_poz_nad) REFERENCES pozice(id_poz);

--
-- Vypisuji data pro tabulku pozice
--

INSERT INTO Pozice (id_poz, nazev, plat, id_poz_nad) VALUES
(1, 'ředitel', 40000, NULL),
(2, 'sekretářka', 30000, 1),
(3, 'kuchař', 26000, 7),
(4, 'řidič', 22000, 8),
(5, 'uklízečka', 18000, 8),
(6, 'zástupce ředitele', 38000, 1),
(7, 'šéfkuchař', 32000, 6),
(8, 'vedoucí provozu', 35000, 6);

-- U Insertu zlobí pořadí id_poz_nad => nutné vypnout kontrolu cizích klíčů !!!
-- --------------------------------------------------------

--
-- Struktura tabulky mesta
--

CREATE TABLE Mesta (
    id_mes INT PRIMARY KEY AUTO_INCREMENT,
    nazev CHAR(30) NOT NULL
);

--
-- Vypisuji data pro tabulku mesta
--

INSERT INTO Mesta (id_mes, nazev) VALUES
(1, 'Ústí nad Labem'),
(2, 'Teplice'),
(3, 'Děčín'),
(4, 'Most'),
(5, 'Bílina'),
(6, 'Litoměřice'),
(7, 'Úštěk'),
(8, 'Česká Lípa'),
(9, 'Lovosice');

-- --------------------------------------------------------

--
-- Struktura tabulky zakaznici
--

CREATE TABLE zakaznici (
  id_zak int(11) PRIMARY KEY AUTO_INCREMENT,
  jmeno char(15) NOT NULL,
  prijmeni char(20) NOT NULL,
  adresa varchar(50) NOT NULL,
  id_mes INT NOT NULL,
  telefon int(9) UNSIGNED ZEROFILL NOT NULL,
  CONSTRAINT fk_mesto FOREIGN KEY (id_mes) REFERENCES mesta (id_mes)
) ENGINE=InnoDB;

--
-- Vypisuji data pro tabulku zakaznici
--

INSERT INTO zakaznici (id_zak, jmeno, prijmeni, adresa, id_mes, telefon) VALUES
(1, 'Marek', 'Balta', 'Na stráni 15, Ústí nad Labem, 40001', 1, 123654789),
(2, 'Josef', 'Hanousek', 'Pod svahem 24, Ústí nad Labem, 40003', 1, 123456987),
(3, 'Karel', 'Habart', 'U parku 3, Teplice, 45001', 2, 321456789),
(4, 'Martin', 'Havruška', 'Dlouhá 46/7, Teplice, 45004', 2, 321654789),
(5, 'Ondřej', 'Chadar', 'Krátká 159/4, Děčín, 43001', 3, 321654987),
(6, 'Matouš', 'Kulina', 'Široká 16, Děčín, 43001', 3, 123654987),
(7, 'Jan', 'Kamský', 'Úzká 73, Teplice, 45002', 2, 321456987),
(8, 'Adam', 'Krhout', 'Na kopečku 2, Ústí nad Labem, 40009', 1, 147258369),
(9, 'Zdeněk', 'Matoušek', 'Nábřeží 18, Děčín, 43001', 3, 147258963),
(10, 'Vojtěch', 'Mileda', 'Za hradem 61, Ústí nad Labem, 40003', 1, 147852369);

-- --------------------------------------------------------

--
-- Struktura tabulky zamestnanci
--

CREATE TABLE zamestnanci (
  id_zam int(11) PRIMARY KEY,
  jmeno char(15) NOT NULL,
  prijmeni char(20) NOT NULL,
  dat_nas date NOT NULL,
  adresa varchar(50) NOT NULL,
  telefon int(9) UNSIGNED ZEROFILL NOT NULL,
  mail varchar(40),
  dat_nar date NOT NULL,
  id_poz int(11) NOT NULL,
  odmena mediumint(6) UNSIGNED NOT NULL,
  CONSTRAINT fk_pozice FOREIGN KEY (id_poz) REFERENCES pozice (id_poz)
) ENGINE=InnoDB;

--
-- Vypisuji data pro tabulku zamestnanci
--

INSERT INTO zamestnanci (id_zam, jmeno, prijmeni, dat_nas, adresa, telefon, mail, dat_nar, id_poz, odmena) VALUES
(1, 'Karel', 'Král', '2015-01-01', 'Na stráni 15, Děčín', 123456789, 'karel.kral@seznam.cz', '1995-10-12', 1, 15000),
(2, 'Eva', 'Tichá', '2015-01-15', 'Spartakiádní 14, Liberec', 789123456, 'eva.ticha@centrum.cz', '1997-09-07', 2, 8000),
(3, 'Jan', 'Novák', '2015-02-01', 'Krátká 8, Ústí nad Labem', 456789123, 'jan.novak@gmail.com', '1992-04-15', 3, 10000),
(4, 'Marek', 'Plachý', '2015-02-01', 'Pod lesem 79, Teplice', 987654321, 'marek.plachy@seznam.cz', '1989-02-28', 4, 5000),
(5, 'Jana', 'Krátká', '2015-03-01', 'V úvozu 3, Děčín', 654321987, 'jana.kratka@centrum.cz', '1991-03-21', 3, 8000),
(6, 'Adam', 'Pyšný', '2015-03-01', 'U hradeb 8, Děčín', 987123654, 'adam.pysny33@seznam.cz', '1994-03-21', 4, 4000),
(7, 'Anna', 'Nová', '2015-03-12', 'Na skřivánku 11/4, Ústí nad Labem', 159368742, 'anickanova@gmail.com', '1998-09-18', 5, 6000),
(8, 'Klára', 'Suchá', '2015-06-01', 'Výstavní 93, Ústí nad Labem', 159863742, 'sucha.klarka@seznam.cz', '1998-12-06', 6, 12000),
(9, 'Martin', 'Ferman', '2015-06-23', 'Neděliště 3, Teplice', 135798642, 'fermartin@post.cz', '1990-08-14', 7, 12000),
(10, 'Emil', 'Konečný', '2015-08-03', 'Sídelní 64/3, Lovosice', 246813579, 'konecnyemilio@gmail.com', '1996-11-16', 8, 9000);

-- --------------------------------------------------------

--
-- Struktura tabulky objednavky
--

CREATE TABLE objednavky (
  cislo int(11) PRIMARY KEY AUTO_INCREMENT,
  dat_pri datetime NOT NULL,
  zam_pri int(11) NOT NULL,
  id_zak int(11) NOT NULL,
  zam_zpr int(11),
  dat_exp datetime,
  zam_exp int(11),
  adr_dor varchar(50),
  CONSTRAINT fk_zam_pri FOREIGN KEY (zam_pri) REFERENCES zamestnanci (id_zam),
  CONSTRAINT fk_zakaznici FOREIGN KEY (id_zak) REFERENCES zakaznici (id_zak),
  CONSTRAINT fk_zam_zpr FOREIGN KEY (zam_zpr) REFERENCES zamestnanci (id_zam),
  CONSTRAINT fk_zam_exp FOREIGN KEY (zam_exp) REFERENCES zamestnanci (id_zam)
) ENGINE=InnoDB;

--
-- Vypisuji data pro tabulku objednavky
--

INSERT INTO objednavky (cislo, dat_pri, zam_pri, id_zak, zam_zpr, dat_exp, zam_exp, adr_dor) VALUES
(10000, '2019-01-04 08:03:00', 1, 1, 3, '2019-01-04 08:15:00', 4, NULL),
(10001, '2019-01-04 08:24:00', 1, 6, 9, '2019-01-04 08:39:00', 4, NULL),
(10002, '2019-01-04 09:01:00', 1, 10, 3, '2019-01-04 09:15:00', 6, NULL),
(10003, '2019-01-04 09:37:00', 2, 8, 3, '2019-01-04 09:59:00', 6, 'K oboře 12, Dolní Zálezly'),
(10004, '2019-01-04 10:11:00', 2, 3, 9, '2019-01-04 10:28:00', 4, NULL),
(10005, '2019-01-04 10:27:00', 2, 5, 3, '2019-01-04 10:44:00', 4, NULL),
(10006, '2019-01-04 11:47:00', 1, 7, 9, '2019-01-04 12:06:00', 6, NULL),
(10007, '2019-01-04 12:31:00', 8, 4, 5, '2019-01-04 12:45:00', 6, NULL),
(10008, '2019-01-04 13:18:00', 8, 2, 5, '2019-01-04 13:33:00', 4, NULL),
(10009, '2019-01-04 14:07:00', 8, 9, 9, '2019-01-04 14:20:00', 4, 'Dlouhá 3, Hostovice'),
(10010, '2019-01-05 09:08:00', 1, 8, 9, '2019-01-05 09:25:00', 6, NULL),
(10011, '2019-01-05 09:23:00', 1, 3, 5, '2019-01-05 09:41:00', 6, NULL),
(10012, '2019-01-05 10:17:00', 1, 7, 5, '2019-01-05 10:41:00', 6, NULL),
(10013, '2019-01-05 10:48:00', 2, 2, 9, '2019-01-05 11:07:00', 6, NULL),
(10014, '2019-01-05 11:14:00', 2, 4, 5, '2019-01-05 11:39:00', 6, 'Na stráni 9, Bukov'),
(10015, '2019-01-05 12:06:00', 8, 10, 3, '2019-01-05 12:22:00', 6, NULL),
(10016, '2019-01-05 12:24:00', 8, 9, 3, '2019-01-05 12:45:00', 4, NULL),
(10017, '2019-01-05 12:52:00', 8, 5, 9, '2019-01-05 13:09:00', 4, NULL),
(10018, '2019-01-05 13:41:00', 2, 1, 9, '2019-01-05 14:01:00', 4, NULL),
(10019, '2019-01-06 09:03:00', 2, 9, 9, '2019-01-06 09:25:00', 4, NULL),
(10020, '2019-01-06 09:12:00', 2, 4, 9, '2019-01-06 09:47:00', 4, NULL),
(10021, '2019-01-06 09:48:00', 2, 2, 5, '2019-01-06 10:01:00', 4, NULL),
(10022, '2019-01-06 10:00:00', 10, 8, 5, '2019-01-06 10:23:00', 4, NULL),
(10023, '2019-01-06 10:38:00', 10, 5, 9, '2019-01-06 10:59:00', 4, NULL),
(10024, '2019-01-06 11:29:00', 1, 3, 5, '2019-01-06 11:48:00', 4, NULL),
(10025, '2019-01-06 12:42:00', 1, 1, 3, '2019-01-06 12:57:00', 6, NULL),
(10026, '2019-01-06 13:51:00', 1, 7, 3, '2019-01-06 14:15:00', 6, NULL),
(10027, '2019-01-07 08:07:00', 10, 5, 9, '2019-01-07 08:23:00', 6, 'Nádražní 45, Svádov'),
(10028, '2019-01-07 08:26:00', 10, 8, 9, '2019-01-07 08:45:00', 6, NULL),
(10029, '2019-01-07 08:53:00', 10, 10, 3, '2019-01-07 09:11:00', 6, NULL),
(10030, '2019-01-07 09:31:00', 10, 3, 3, '2019-01-07 09:46:00', 6, NULL),
(10031, '2019-01-07 10:37:00', 2, 6, 3, '2019-01-07 10:59:00', 6, 'Radlická 2, Brná'),
(10032, '2019-01-07 11:23:00', 2, 9, 3, '2019-01-07 11:38:00', 6, NULL),
(10033, '2019-01-07 11:59:00', 2, 4, 9, '2019-01-07 12:27:00', 4, 'Plátenická 12/7, Krásné Březno'),
(10034, '2019-01-07 12:26:00', 8, 2, 5, '2019-01-07 12:51:00', 4, NULL),
(10035, '2019-01-07 13:43:00', 8, 1, 5, '2019-01-07 14:07:00', 4, NULL),
(10036, '2019-01-08 08:06:00', 4, 7, 9, '2019-01-08 08:28:00', 4, NULL),
(10037, '2019-01-08 08:25:00', 1, 6, 3, '2019-01-08 08:51:00', 4, NULL),
(10038, '2019-01-08 09:14:00', 1, 2, 3, '2019-01-08 09:29:00', 4, NULL),
(10039, '2019-01-08 09:35:00', 1, 9, 9, '2019-01-08 09:57:00', 4, NULL),
(10040, '2019-01-08 10:41:00', 2, 1, 5, '2019-01-08 10:59:00', 4, 'Jana Palacha 17, Skorotice'),
(10041, '2019-01-08 11:18:00', 2, 5, 5, '2019-01-08 11:35:00', 4, NULL),
(10042, '2019-01-08 11:39:00', 2, 8, 9, '2019-01-08 12:04:00', 6, NULL),
(10043, '2019-01-08 12:17:00', 10, 3, 9, '2019-01-08 12:38:00', 6, NULL),
(10044, '2019-01-08 13:42:00', 10, 7, 5, '2019-01-08 14:01:00', 6, NULL),
(10045, '2019-01-09 08:07:00', 8, 9, 5, '2019-01-09 08:34:00', 4, NULL),
(10046, '2019-01-09 08:39:00', 8, 6, 9, '2019-01-09 09:06:00', 4, NULL),
(10047, '2019-01-08 09:17:00', 8, 2, 9, NULL, NULL, NULL),
(10048, '2019-01-08 09:32:00', 1, 10, 3, NULL, NULL, 'Nádražní 28, Dolní Zálezly'),
(10049, '2019-01-08 10:03:00', 1, 1, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Struktura tabulky adresy_faktur
--

CREATE OR REPLACE TABLE Adresy_faktur(
    cislo INT PRIMARY KEY,
    nazev_firmy CHAR(30) NOT NULL,
    ico INT NOT NULL,
    dic VARCHAR(12) NOT NULL,
    adr_fakt VARCHAR(50) NOT NULL,
    FOREIGN KEY (cislo) REFERENCES objednavky(cislo)
);

--
-- Vypisuji data pro adresy_faktur
--

INSERT INTO adresy_faktur (cislo, nazev_firmy, ico, dic, adr_fakt) VALUES
(10006, 'Hořička a syn', 123456789, 'CZ123456789', 'Tovární 15, Bystřice'),
(10022, 'Novaokna s r.o.', 3456789012, 'CZ3456789012', 'Husitská 9, Krupka'),
(10037, 'Motospeed-MK', 98764321, 'CZ98764321', 'Na vršku 3, Proboštov');

-- --------------------------------------------------------

--
-- Struktura tabulky vyrobky
--

CREATE TABLE vyrobky (
  id_vyr int(11) PRIMARY KEY,
  nazev char(50) UNIQUE NOT NULL,
  cena decimal(6,2) NOT NULL,
  id_dru int(11) NOT NULL,
  popis varchar(90),
  CONSTRAINT fk_druh FOREIGN KEY (id_dru) REFERENCES druhy_vyrobku (id_dru)
) ENGINE=InnoDB;

--
-- Vypisuji data pro tabulku vyrobky
--

INSERT INTO vyrobky (id_vyr, nazev, cena, id_dru, popis) VALUES
(10, 'dóner kebab', '75.00', 4, 'maso, salát, omáčka'),
(11, 'dóner kebab balkán', '85.00', 4, 'maso, salát, omáčka, balkánský sýr'),
(12, 'dóner kebab falafel', '100.00', 4, 'maso, salát, omáčka, falafel'),
(13, 'dóner kebab halloumi', '100.00', 4, 'maso, salát, omáčka, halloumi'),
(14, 'dóner kebab hawai', '85.00', 4, 'maso, salát, omáčka, ananas'),
(15, 'dóner kebab pizza sýr', '85.00', 4, 'maso, salát, omáčka, pizza sýr'),
(16, 'kebab vegetariana', '65.00', 4, 'salát, omáčka, zelenina'),
(17, 'malý dóner kebab', '49.00', 4, 'maso, salát, omáčka'),
(18, 'super dóner kebab', '100.00', 4, 'maso, salát, omáčka'),
(20, 'insalata coban', '60.00', 1, 'rajčata, okurka, cibule, paprika'),
(21, 'insalata Dóner', '100.00', 1, 'zeleninový salát, maso'),
(22, 'insalata falafel', '85.00', 1, 'zeleninový salát, falafel'),
(23, 'insalata halloumi', '100.00', 1, 'zeleninový salát, sýr halloumi'),
(24, 'insalata mozzarela', '75.00', 1, 'rajčata, olivový olej, bazalka, mozzarela'),
(30, 'insalata mista colorata', '63.00', 1, 'míchaný salát'),
(31, 'insalata al salmone', '129.00', 1, 'míchaný salát, rest. kousky lososa, krutony, rajčata, hořčic. dressing'),
(32, 'insalata belucci', '125.00', 1, 'míchaný salát, gril. kuřecí prsa, pomeranč, jablka, ořechy, dressing, javorový sirup'),
(33, 'insalata con tonno', '117.00', 1, 'míchaný salát, tuňák, cibule, vejce, růžový dressing'),
(38, 'insalata greca', '109.00', 1, 'rajčata, paprika, okurky, cibule, olivy, kopr, balkánský sýr'),
(39, 'insalata croccante', '139.00', 1, 'míchaný salát, kuřecí nugetky obalené v cornflakes, hořčic. dressing'),
(40, 'insalata caesar', '128.00', 1, 'ledový salát, kuřecí prsa, česnekový dressing, krutony, parmazán'),
(41, 'insalata con schiacciate di patate e tagliatta', '141.00', 1, 'míchaný salát, brambor. placičky, plátky vepřové panenky, hořčic. dressing'),
(50, 'focaccia', '49.00', 2, 'pizza chléb s rozmarýnem a olivovým olejem'),
(51, 'trappola', '145.00', 2, 'rajčata, mozzarella, kuřecí maso, slanina, kukuřice, česnek, brokolice'),
(52, 'margherita', '98.00', 2, 'rajčata, mozzarella, bazalka'),
(53, 'capricciosa', '119.00', 2, 'rajčata, mozzarella, šunka, žampiony, bazalka'),
(54, 'calzone - plněná', '122.00', 2, 'rajčata, mozzarella, šunka, žampiony, bazalka'),
(55, 'loci', '149.00', 2, 'rajčata, mozzarella, slanina, vepřová panenka, česnek, oregáno, brokolice, paprika'),
(56, 'carpaccio', '155.00', 2, 'rajčata, plátky svíčkové, smetana, parmazán, rozmarýn, mozzarella'),
(57, 'frutti di mare', '149.00', 2, 'rajčata, mozzarella, mořské plody'),
(58, 'quattro formaggi', '157.00', 2, 'smetana, mozzarella, gorgonzola, parmazán, ricotta'),
(59, 'quattro stagioni', '123.00', 2, '1/4 Marinara, 1/4 Margherita, 1/4 Capricciosa, 1/4 Frutti di mare'),
(60, 'hawai', '127.00', 2, 'rajčata, mozzarella, šunka, ananas'),
(61, 'salamino', '123.00', 2, 'rajčata, mozzarella, salám'),
(62, 'messicana', '131.00', 2, 'rajčata, mozzarella, salám, cibule, vejce, pikantní olivový olej'),
(63, 'pancetta', '119.00', 2, 'rajčata, mozzarella, žampiony, slanina'),
(64, 'fausto', '115.00', 2, 'rajčata, mozzarella, žampiony, olivy'),
(65, 'bolzano', '149.00', 2, 'smetana, mozzarella, kuřecí maso, gorgonzola, chřest, rozmarýn, česnek'),
(66, 'tonno', '121.00', 2, 'rajčata, mozzarella, tuňák, cibule'),
(67, 'funghi', '105.00', 2, 'rajčata, mozzarella, žampiony, vejce'),
(68, 'napolitana', '125.00', 2, 'rajčata, mozzarella, italská klobása, fazole, sušená rajčata, parmazán'),
(69, 'rustica', '159.00', 2, 'rajčata, kuřecí maso, mozzarella, gorgonzola, parmazán'),
(70, 'emiliano', '129.00', 2, 'smetana, mozzarella, šunka, tuňák, cibule'),
(71, 'prosciutto e olive', '127.00', 2, 'rajčata, mozzarella, šunka, olivy'),
(72, 'bolognese', '134.00', 2, 'rajčata, mozzarella, hovězí a vepřové maso, cibule'),
(73, 'vegetariana', '125.00', 2, 'rajčata, mozzarella, listový špenát, kukuřice, chřest'),
(74, 'prosciutto crudo', '149.00', 2, 'rajčata, mozzarella, parmská šunka, bazalka'),
(75, 'con salmone e spinaci fresco', '151.00', 2, 'smetana, mozzarella, losos, čerstvý špenát, citron'),
(76, 'bradipo', '127.00', 2, 'rajčata, mozzarella, brambory, slanina, vejce, rozmarýn'),
(77, 'peperoni e salsiccia', '134.00', 2, 'rajčata, mozzarella, pikantní klobása, feferonky - beraní rohy, cibule, kukuřice'),
(78, 'pollo e spinaci', '149.00', 2, 'smetana, kuřecí maso, červené fazole, listový špenát, kukuřice'),
(79, 'brava', '139.00', 2, 'rajčata, mozzarella, slanina, špenát, vejce, parmazán, oregáno'),
(80, 'adane', '115.00', 2, 'rajčata, pizza sýr, turecký sucuk, feta sýr, cibule, žampiony'),
(81, 'al broccoli', '114.00', 2, 'salza, smetana, sýr, brokolice, česnek'),
(82, 'al salmone', '158.00', 2, 'rajčata, mozzarela, uzený losos, krevetky'),
(83, 'al tonno', '125.00', 2, 'rajčata, mozzarela, tuňák, cibule'),
(84, 'con salsiccia', '169.00', 2, 'salza, papriková klobása, cibule, sýr'),
(85, 'emilia', '145.00', 2, 'smetana, cibule, tuňák, sýr, olivy'),
(86, 'lago di garda', '136.00', 2, 'salza, šunka, sýr, kukuřice'),
(87, 'spaghetti pollo pikant', '79.00', 3, 'salza, chilli, sýr, kozí rohy'),
(88, 'spaghetti pollo spinaci', '95.00', 3, 'smetana, česnek, špenát'),
(89, 'spaghetti al´aglio e olio', '89.00', 3, 'olivový olej, česnek, parmazán'),
(90, 'spaghetti alla carbonara', '119.00', 3, 'slanina, smetana, vejce, cibule, parmazán'),
(91, 'spaghetti con filetto e funghi', '153.00', 3, 'smetana, hovězí svíčková, hřiby, bílé víno, parmazán'),
(92, 'spaghetti all´amatriciana', '121.00', 3, 'slanina, cibule, rajčata, chilli, parmazán, bílé víno'),
(93, 'spaghetti bolognese', '97.00', 3, '\''),
(94, 'fusilli saporiti', '139.00', 3, 'kuřecí maso, brokolice, smetana, gorgonzola, parmazán'),
(95, 'fusilli spinaci e pollo', '139.00', 3, 'kuřecí maso, listový špenát, smetana, parmazán, česnek'),
(96, 'fusilli boscaiola', '121.00', 3, 'žampiony, šunka, hrášek, smetana, parmazán'),
(97, 'fusilli trappola', '139.00', 3, 'rajčata, hovězí svíčková, rozmarýn, chilli, parmazán, smetana'),
(98, 'fusilli al pomodoro fresco', '128.00', 3, 'čerstvá rajčata, bazalka, mozzarella, parmazán, česnek'),
(99, 'penne al curry', '135.00', 3, 'kuřecí maso, hrášek, žampiony, smetana, kari, parmazán'),
(100, 'penne alla ricotta - zapečeno', '138.00', 3, 'kuřecí maso, ricotta, smetana, mozzarella'),
(101, 'penne all´arabbiata', '98.00', 3, 'rajčata, cibule, česnek, chilli, parmazán, česnek'),
(103, 'penne con salsiccia', '129.00', 3, 'čerstvá rajčata, italská klobása, cibule, paprika, parmazán'),
(105, 'tagliatelle al salmone', '145.00', 3, 'losos, smetana, bílé víno, parmazán, česnek'),
(106, 'tagliatelle alla bolognese', '127.00', 3, 'hovězí a vepřové mleté maso, rajčata, parmazán, česnek'),
(109, 'gnocchi piccante al forno', '128.00', 3, 'zapečené bramborové noky, vepřová panenka, kukuřice, paprika, olivy, chilli'),
(111, 'gnocchi con funghi e rucola', '119.00', 3, 'bramborové noky, hřiby, rukola, smetana, parmazán'),
(112, 'gnocchi quattro formaggi', '135.00', 3, 'bramborové noky, parmazán, gorgonzola, mozzarella, ricotta, smetana'),
(113, 'gnocchi con spinaci', '119.00', 3, 'bramborové noky, listový špenát, smetana, česnek, parmazán'),
(114, 'gnocchi al forno con prosciutto crudo', '125.00', 3, 'zapečené bramborové noky, parmská šunka, rajčata, mozzarella, žampiony'),
(115, 'patate al forno', '99.00', 3, 'brambory, smetana, parmská šunka, parmazán'),
(116, 'risi bisi', '135.00', 3, 'kuřecí maso, slanina, hrášek, cibule, parmazán'),
(117, 'risotto con spinaci e mozzarella', '127.00', 3, 'špenát, mozzarella, parmazán, cibule, smetana'),
(118, 'risotto con funghi porcini', '139.00', 3, 'hřiby, máslo, parmazán, cibule, bílé víno'),
(119, 'fusilli bolognese', '127.00', 3, 'mleté maso, bazalka'),
(120, 'fusilli pollo spinaci', '119.00', 3, 'smetana, česnek, špenát'),
(121, 'fusilli pollo pikant', '132.00', 3, '\''),
(130, 'lahmacun', '60.00', 2, 'turecká pizza'),
(131, 'nuova', '125.00', 2, 'rajčata, mozzarela, salám, špenát, cibule, vejce, smetana, česnek'),
(132, 'piccante', '135.00', 2, 'rajčata, mozzarela, slanina, salám, chilli, kozí rohy'),
(133, 'pollo al curry', '142.00', 2, 'smetana, mozzarela, žampiony, hrášek, kuřecí maso, kari'),
(134, 'pollo gyros con panna', '205.00', 2, 'smetana, česnek, kuřecí gyros, sýr'),
(135, 'pollo gyros pikant', '210.00', 2, 'salza, chilli, kuřecí gyros, sýr, kozí rohy'),
(136, 'pollo spinaci', '122.00', 2, 'smetana, kuřecí směs s česnekem a špenátem'),
(137, 'pomodori funghi', '119.00', 2, 'salza, sýr, rajčata, žampiony'),
(138, 'quattro salami', '149.00', 2, 'rajčata, mozzarela, salám pikant, slanina, šunka, klobása'),
(139, 'reggina', '115.00', 2, 'rajčata, pizza sýr, šunka, salám, cibule'),
(140, 'roma', '134.00', 2, 'rajčata, mozzarela, šunka, žampiony, olivy, kozí rohy, vejce'),
(141, 'sardine', '100.00', 2, 'rajčata, pizza sýr, sardinky'),
(142, 'siciliana', '137.00', 2, 'rajčata, mozzarela, ančovičky, cibule, kapary'),
(143, 'tomino', '135.00', 2, 'rajčata, mozzarela, šunka, žampiony, brokolice, kuřecí maso'),
(144, 'tre salami', '96.00', 2, 'salza, sýr, šunka, paprikový salám, slanina'),
(146, 'tutti all aglio', '184.00', 2, 'česnek, salza, sýr, dušená šunka, slanina'),
(147, 'tutti all pollo', '179.00', 2, 'smetana, kuřecí pikantní směs, sýr'),
(148, 'tutti pizza', '154.00', 2, 'smetana, hermelín, niva, paprika, sýr'),
(149, 'tutti sicilliana', '149.00', 2, 'smetana, slanina, vejce, sýr'),
(200, 'Cappy pomeranč', '24.00', 5, 'pomerančový juice 100%, 330ml'),
(201, 'Cappy jablko', '24.00', 5, 'jablečný juice 100%, 330ml'),
(202, 'Cappy multivitamín', '24.00', 5, 'multivitamín 50%, 330ml'),
(203, 'Red Bull', '35.00', 5, 'Energy Drink osvěží tělo i mysl, zvýší výkon, soustředění, bdělost a rychlost reakce, 250ml'),
(204, 'Semtex', '33.00', 5, 'Energy Drink s obsahem kofeinu, taurinu, s přídavkem vitamínů, 250ml'),
(205, 'Fanta', '21.00', 5, 'nápoj s pomerančovou příchutí, 200ml'),
(206, 'Sprite', '23.00', 5, 'svěží, čistá chuť, která skutečně hasí žízeň, 200ml'),
(207, 'Coca cola', '25.00', 5, 'hnědý sladký nápoj s obsahem kofeinu a bezkokainového výtažku koky, 200ml'),
(208, 'Aquila jemně perlivá', '18.00', 5, 'voda z hlubin skal sopečného původu u Karlových Varů, obsahuje minerály, 330ml'),
(209, 'voda', '15.00', 5, 'pitná voda z kohoutku, 500ml');

-- --------------------------------------------------------

--
-- Struktura tabulky obj_vyr
--

CREATE TABLE obj_vyr (
  cislo int(11) NOT NULL,
  id_vyr int(11) NOT NULL,
  kusy tinyint(4) DEFAULT 1,
  CONSTRAINT fk_objednavky FOREIGN KEY (cislo) REFERENCES objednavky (cislo) ON DELETE CASCADE,
  CONSTRAINT fk_vyrobky FOREIGN KEY (id_vyr) REFERENCES vyrobky (id_vyr)
) ENGINE=InnoDB;

--
-- Vypisuji data pro tabulku obj_vyr
--

INSERT INTO obj_vyr (cislo, id_vyr, kusy) VALUES
(10000, 30, 1),
(10000, 51, 1),
(10000, 50, 1),
(10001, 60, 5),
(10001, 200, 3),
(10002, 94, 1),
(10002, 61, 1),
(10002, 67, 1),
(10003, 61, 2),
(10003, 105, 1),
(10004, 30, 1),
(10004, 50, 1),
(10004, 67, 2),
(10004, 60, 1),
(10005, 32, 1),
(10005, 205, 1),
(10006, 50, 1),
(10007, 59, 1),
(10007, 203, 1),
(10008, 98, 2),
(10008, 59, 1),
(10009, 90, 1),
(10010, 41, 1),
(10010, 92, 1),
(10010, 208, 2),
(10011, 66, 4),
(10012, 51, 1),
(10012, 207, 1),
(10013, 58, 3),
(10014, 113, 1),
(10015, 41, 1),
(10015, 67, 2),
(10016, 58, 1),
(10016, 51, 1),
(10016, 65, 1),
(10017, 57, 4),
(10017, 201, 2),
(10017, 206, 1),
(10018, 30, 1),
(10018, 99, 1),
(10019, 60, 2),
(10019, 69, 1),
(10019, 38, 1),
(10020, 115, 3),
(10021, 62, 1),
(10021, 98, 1),
(10022, 31, 1),
(10023, 68, 3),
(10023, 208, 2),
(10024, 56, 1),
(10024, 60, 2),
(10024, 64, 1),
(10025, 118, 1),
(10025, 38, 2),
(10026, 112, 1),
(10026, 63, 1),
(10027, 51, 1),
(10027, 202, 1),
(10028, 60, 4),
(10029, 70, 1),
(10029, 31, 1),
(10029, 78, 1),
(10030, 53, 1),
(10031, 60, 2),
(10031, 206, 2),
(10032, 54, 4),
(10033, 117, 1),
(10034, 40, 2),
(10034, 109, 1),
(10035, 55, 1),
(10035, 12, 2),
(10035, 21, 4),
(10035, 16, 3),
(10036, 11, 1),
(10036, 31, 2),
(10037, 21, 5),
(10038, 146, 2),
(10038, 61, 1),
(10038, 201, 3),
(10039, 112, 2),
(10040, 139, 1),
(10040, 149, 2),
(10040, 148, 2),
(10041, 144, 1),
(10041, 13, 2),
(10042, 23, 4),
(10042, 15, 1),
(10043, 16, 3),
(10044, 75, 1),
(10044, 146, 2),
(10044, 142, 1),
(10044, 18, 1),
(10045, 13, 2),
(10045, 33, 1),
(10045, 39, 1),
(10046, 140, 4),
(10047, 120, 1),
(10047, 138, 2),
(10047, 116, 1),
(10048, 112, 1),
(10048, 97, 3),
(10049, 91, 4);

COMMIT;

