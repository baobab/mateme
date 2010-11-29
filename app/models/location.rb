class Location < ActiveRecord::Base
  set_table_name "location"
  set_primary_key "location_id"
  has_many :obs, :foreign_key => :location_id
  has_many :patient_identifiers, :foreign_key => :location_id
  has_many :encounters, :foreign_key => :location_id
  belongs_to :parent, :foreign_key => :parent_location_id, :class_name => "Location"
  has_many :children, :foreign_key => :parent_location_id, :class_name => "Location"
  belongs_to :user, :foreign_key => :user_id

  include Openmrs

  cattr_accessor :current_location

  def site_id
    self.description.match(/\(ID=(\d+)\)/)[1] 
  rescue 
    raise "The id for this location has not been set (#{Location.current_location.name}, #{Location.current_location.id})"   
  end

  def Location.get_list
    return @@location_list
  end

  def Location.get_health_facility
    return @@health_facilities
  end

  
  def Location.initialize_location_list
    locations = <<EOF
Amidu
Angelo Goveya
Angels Federation
Army secondary school
B C A
Balaka
Balaza
Baluti
Bangula
Bangwe
Biwi (A8)
Blantyre
Boghoyo
BSS
Bvumbwe
Bwaila
Bwanje
CCDC
Central
Chadza
Chadzunda
Chakhaza
Chakhumbira
Chamba
Champiti
Changata
Chapananga
Chapinduka
Chatha
Chauma
Chavala
Chemboma
Chemusa
Chesomba
Chichiri
Chigaru
Chigumula
Chigumula church
Chigumula market
Chigumula newlands
Chigwaja
Chikho
Chikowa
Chikowi
Chikulamayembe
Chikuli
Chikumbu
Chikwa
Chikwawa
Chikweo
Chiladzulu
Chileka
Chileka roundabout
Chilikumwendo
Chilinde 1 (A21)
Chilinde 2 (A21)
Chilobwe
Chilobwe near chigalu
Chilombo
Chilomoni
Chilomoni near blm
Chilomoni near cath sch
Chilooko
Chilowamatambe
Chilumba
Chimaliro
Chimoka
Chimombo
Chimutu
Chimwala
Chimwankhunda
Chimwankhunda dam
Chindi
Chingwirizano
Chinsapo 1 (A46)
Chinsapo 2 (A46)
Chinyonga
Chipasula
Chipini
Chiradzulu
Chiradzulu pim
Chirimba
Chirimba near chiweto
Chirimba near market
Chirimba near mosque
Chirimba near namatete xool
Chiseka
Chisemphere
Chisikwa
Chiswe
Chitawira
Chitawira near ntonya
Chitedze
Chitekwele
Chitela
Chitera
Chitipa
Chitukula
Chiuzira
Chiwalo
Chiwembe
Chiwere
Chowe
Chulu
CI
Dambe
Dedza
Dowa
Dziwe
Dzoole
Dzumira
Falls
Fargo
Fukamalaza
Fukamapiri
Ganya
Ginnery corner
Golio
Gomani
Green corner
Gulliver (A49)
H H I
Health sciences
Jalasi
Jaravikuwa
Jenala
Juma
Kabango mpemba
Kabudula
Kabula
Kabunduli
Kachenga
Kachere
Kachere market
Kachindamoto
Kachulu
Kadammanja
Kadewere
Kaduya
Kafuzira
Kaipa
Kalembo
Kaliyeka 1
Kaliyeka 2
Kalolo
Kalonga
Kaluluma
Kalumba
Kalumbu
Kalumo
Kamba
Kambalame
Kambwiri
Kameme
Kamenyagwaza
Kameza
Kampala
Kampingo Sibande
Kamuzu Barracks
Kanduku
Kanengo
Kanjedza
Kanjedza forest
Kanjedza police
Kantukule
Kanyenda
Kaomba
Kaondo
Kapelula
Kapeni
Kaphiri
Kaphuka
Kapichi
Kapoloma
Kaponda
Karonga
Kasakula
Kasisi
Kasumbu
Kasungu
Katema
Katuli
Katumbi
Katunga
Kauma
Kawale 1 (A4)
Kawale 2 (A4)
Kawamba
Kawinga
Kayembe
KCN blantyre cumpus
Khama
Khombedza
Khongoni
Khosolo Jere
Khwetemule
Kilupula
Kubaluti
Kuluunda
Kumbendera
Kumtumanji
Kuntaja
Kunthembwe
Kwacha
Kwataine
Kyungu
Laston Njema
Likhubula
Likoma
Likoswe
Likuni
Lilangwe
Lilongwe
Lilongwe City
Limbe
Lingadzi
Lirangwe
Liwonde
Luchenza
Lukwa
Lumbadzi
Lundu
Lunzu
Mabuka
Mabulabo
Machinga
Machinjiri
Machinjiri khama
Madziabango
Magalasi
Maganga
Magasa
Makanjira
Makata
Makheta
Makhetha
Makhuwira
Makoko
Makwangwala
Makwasa
Malanda
Malangalanga Admarc
Malavi
Malemia
Malenga
Malenga Mzoma
Malengachanzi
Malili
Malingamoyo
Mambula
Manase
Manase near temani bottle str
Mandala
Mangochi
Manja
Manja Near Manja FP Xool
Manje
Manjombe
Mankhambira
Manyowe
Maoni
Mapanga
Masasa
Maseya
Masula
Masulani
Masumbankhunda
Maula Prison
Mavwere
Mazengera
Maziabango
Mbawa
Mbawela
Mbayami near zikomo lge
Mbayana
Mbayani
Mbayani Near Kayange
Mbayani near market
Mbayani near mbayani primary
Mbayani near mboni
Mbayani near the market
Mbayani near zandeya
Mbelwa 4
Mbenje
Mbiza
Mbora
Mbulumbuzi
Mchesi (A8)
Mchezi
Mchinji
Mdala
Mdeka
Mduwa
Medical line
Mgabu
Mgona
Michiru
Milale
Milale forest
Misesa
Mitsidi
Mkanda
Mkhumba
Mkolokoti
Mkondowe
Mkumbila
Mkumbira
Mkumpha
Mlauli
Mlilima
Mlolo
Mlomba
Mlonyeni
Mlumbe
Mmbwananyambi
Mneno
Mnyanja
Moneymen
Monjeza
Mount pleasant
Mozambique
Mpama
Mpando
Mpemba
Mpherembe
Mphonde
Mphuka
Mpingwe
Mponda
Mponela
Mposa
Mpunga
Msakambewa
Msamala
Mselema
Mselemu
Msiska
Msosa
Msuli
Msusa
Mtambalika
Mtandire
Mtenje
Mthandizi
Mthiramanja
Mtonda
Mtsiliza
Mtwalo
Mudi
Mudi forest
Muhepo
Mulanje
Mulenga
Mulumbe
Mwadzama
Mwahenga
Mwakaboko
Mwalweni
Mwambo
Mwamlowe
Mwangata
Mwankunikira
Mwansambo
Mwanza
Mwarangombe
Mwase
Mwaulambya
Mwenemisuku
Mwenewenya
Mwenyekondo
Mzikubola
Mzimba
Mzuzu
Mzuzu-zuku
Namabvi
Namatabwa
Namatapa
Namingomba
Namiwawa
Namiyango
Namonde
Nancholi
Nangumi
Nanholi
Nankumba
Naotcha
Naperi
Naperi near qech
Nazombe
Nchalo
Nchembere
Nchilamwera
Ndamera
Ndindi
Ndirande
Ndirande chinseu
Ndirande makata
Ndirande newlines
Neno
New naperi
Newfargo
Ngabu
Ngokwe
Ngozi
Nguludi
Ngumbe
Ngwenya
Nicholas
Njamba
Njewa
Njolomole
Njombwa
Nkalo
Nkaya
NkhataBay
Nkhata-Bay
Nkhota-kota
Nkhumba
Nkhumbe
Nkokokoti
Nkolokosa
Nkolokoti
Nkoola
Nkukula
Nkula
Nkula waterboard
Northern
Nsabwe
Nsanama
Nsanje
Nsomba
Nsusa
Ntchema
Ntcheu
Ntchisi
Ntema
Ntenje
Nthache
Nthalire
Nthiramanja
Nthondo
Nthunduwala
Ntonda
Ntopwa
Nyachikadza
Nyaluwanga
Nyambadwe
Nyambi
Open Arms
Pemba
Pensulo
Phalombe
Phalula
Phambala
Phwetekere
Piasani
Police Mobile Force
Polytechnic
Prison
Railways
Rumphi
Salima
Same
Sangamiza
Sanjika
Santhe
Santi
Sawali
Sigelege
Simphasi
Simulemba
Sitola
Siyaye
Soche
Soche East
Soche Federation
Soche Hill
Soche Police
Soche Quary
Somba
Songolo village
SOS Village
Southern
State House
Stella marris
Sunny side
Sunnyside
Sunside
Sunyside
Suya
Symon
Tambala
Tambo 1
Tengani
Tete
Thomasi
Thuchila
Thukuta
Thumbwe clinic
Thyolo
Timbiri
Tsabango
Tsikulamowa
TVM
Unknown
Wenela
Wico staff houses
Wimbe
Zalewa
Zambia
Zilakoma
Zimbabwe
Zingwangwa
Zobwe
Zolokere
Zomba
Zulu
EOF
    return locations.split("\n")
  end

  def Location.initialize_health_facilities
     facilities = <<EOF
Unknown
Other
Aa-salam Clinic
Admarc Dispensary
Adventist Health Centre
African Bible College Health Centre
Alinafe Rehabilitation Centre
Area 18 Urban Health Centre
Area 25 Banja La Mtsogolo Dispensary
Area 25 Urban Health Centre
Balaka District Health Office
Balaka District Hospital
Balaka Health Area
Balaka Health District
Balaka OPD Health Centre
Bangwe Health Centre
Bembeke Health Centre
Benga Health Centre
Bilal Dispensary
Bilira Health Centre
Bimbi Health Centre
Biriwiri Health Centre
Blantyre Civic Centre Dispensary
Blantyre District Health Office
Blantyre Health Area
Blantyre Health District
Bolero Health Centre
Bondo Health Centre
Bowe Health Centre
Bua Dispensary (Kasungu)
Bua Dispensary (Nkhotakota)
Bula Health Centre
Bulala Health Centre
Bvumbwe Research Health Centre
Bvumbwe-Makungwa Health Centre
Bwanje Health Centre
Bwengu Health Centre
Chabvala Health Centre
Chadza Health Centre
Chakhaza Health Centre
Chamba Dispensary (Machinga)
Chamba Dispensary (Zomba)
Chambe Health Centre
Chambo Health Centre
Chamwabvi Dispensary
Chang'Ambika Health Centre
Changata Health Centre
Chankhungu Health Centre
Chapananga Health Centre
Chesamu Health Centre
Chezi Dispensary
Chididi Health Centre (Nkhotakota)
Chididi Health Centre (Nsanje)
Chiendausiku Health Centre
Chifunga Health Centre
Chigodi Health Centre
Chikande Health Centre
Chikangawa Health Centre
Chikole Dispensary
Chikowa Health Centre (Blantyre)
Chikowa Health Centre (Lilongwe)
Chikuse Health Centre
Chikwawa District Health Office
Chikwawa District Hospital
Chikwawa Health Area
Chikwawa Health District
Chikweo Health Centre
Chikwina Health Centre
Chilambwe Health Centre
Chileka Health Centre
Chileka Health Centre (Lilongwe)
Chileka Sda Health Centre
Chilipa Health Centre (Mangochi)
Chilipa Health Centre (Zomba)
Chilobwe Majiga Health Centre
Chilomoni Health Centre
Chilumba Garrison Dispensary
Chilumba Rural Hospital
Chimaliro Health Centre
Chimbalanga Health Centre
Chimembe Health Centre
Chimoto Health Centre
Chimvu Health Centre
Chimwala Dispensary
Chingoma Dispensary
Chingale Health Centre
Chingazi Health Centre
Chinguluwe Health Centre (Ntchisi)
Chinguluwe Health Centre (Salima)
Chinkhwiri Health Centre
Chinsapo Dispensary
Chintheche Rural Hospital
Chinthembwe Health Centre
Chinyama Health Centre
Chioshya Health Centre
Chipho Health Centre
Chipini Health Centre
Chipoka Health Centre
Chiponde Health Centre
Chipumi Health Centre
Chipwaila Health Centre
Chipwanya St Josephs Health Centre
Chiradzulu District Health Office
Chiradzulu District Hospital
Chiradzulu Health Area
Chiradzulu Health District
Chiringa Dispensary
Chiringa Maternity
Chisala Health Centre
Chisepo Health Centre
Chisinga Dispensary
Chisitu Health Centre
Chitala Health Centre
Chitedze Health Centre
Chitekesa Health Centre
Chitera Health Centre
Chitheka Health Centre
Chithumba Maternity
Chitimba Health Centre
Chitipa District Health Office
Chitipa District Hospital
Chitipa Health Area
Chitipa Health District
Chitowo Health Centre
Chiumbangame Health Centre
Chiunjiza Health Centre
Chiwamba Health Centre
Chiwe Health Centre
Chizumulo St Marys Health Centre
Choma Health Centre
Chonde Health Centre
Chongoni Health Centre
Chulu Health Centre
City Assembly Dispensary
Cobbe Barracks Hospital
Dedza District Health Office
Dedza District Hospital
Dedza Health Area
Dedza Health District
DGM Livingstonia Hospital
Diamphwe Health Centre
Dickson Health Centre
Dolo Health Centre
Domasi Rural Hospital
Doviko Dispensary
Dowa District Health Office
Dowa District Hospital
Dowa Health Area
Dowa Health District
Dwambazi Health Centre
Dwambazi Rural Hospital
Dwangwa Can Growers Limited Clinic
Dwangwa Dispensary
Dzalanyama Dispensary
Dzeleka Refugee Camp Health Centre
Dzenje Maternity
Dzenza Health Centre
Dzindevu Health Centre
Dziwe Dispensary
Dzonzi-Mvai Health Centre
Dzoole Health Centre
Dzunje Dispensary
Edingeni Rural Hospital
Ehehleni Dispensary
Ekwaiweni Dispensary
Ekwendeni Hospital
Embangweni Hospital
Emfeni Health Centre
Emsizini Health Centre
Endindeni Health Centre
Engucwini Dispensary
Enukweni Health Centre
Euthini Rural Hospital
Falls Banja La Mtsogolo Dispensary
Fulirwa Health Centre
Gaga Health Centre
Ganya Maternity
Gawanani Health Centre
Gogode Dispensary
Gola Dispensary
Golomoti Health Centre
Gombe Maternity
Gowa Health Centre
Guilleme St Michaels Health Centre
H Parker Sharp Dispensary
Hallena Oakely Health Centre
Hara Dispensary
Hoho Health Centre
Iba Health Centre
Ifumbo Health Centre
Iponga Health Centre
Jalasi Health Centre
Jenda Health Centre
Kabudula Health Area
Kabudula Rural Hospital
Kabuwa Health Centre
Kabwafu Health Centre
Kachale Health Centre
Kachere Health Centre
Kafele Health Centre
Kafukule Health Centre
Kaigwazanga Health Centre
Kakoma Health Centre
Kalemba Health Centre
Kalembo Dispensary
Kalikumbi Health Centre
Kalinde Dispensary
Kaloga Dispensary
Kalulu Health Centre
Kaluluma Rural Hospital
Kambenje Health Centre
Kamboni Health Centre
Kameme Health Centre
Kampanje Maternity
Kamphata Dispensary
Kamsonga Health Centre
Kamteteka Health Centre
Kamuzu Barracks Dispensary
Kamwe Health Centre
Kande Health Centre
Kandeu Dispensary
Kangoma Health Centre
Kangolwa Health Centre
Kankao Health Centre
Kanyama Health Centre
Kanyezi Health Centre
Kanyimbi Dispensary
Kaombe Dispensary
Kapanga Health Centre
Kapelula Health Centre
Kapenda Health Centre
Kapeni Health Centre
Kaphatenga Health Centre
Kaphuka Health Centre
Kapichila (ESCOM) Health Centre
Kapili Health Centre
Kapire Health Centre
Kapiri Health Centre
Kaporo Rural Hospital
Karonga District Health Office
Karonga District Hospital
Karonga Health Area
Karonga Health District
Kasalika Dispensary
Kaseye St Michaels Health Centre
Kasina Health Centre
Kasinje Health Centre
Kasinthula Dispensary
Kasitu Dispensary
Kasitu Health Centre
Kasiya Health Centre
Kasungu District Health Office
Kasungu District Hospital
Kasungu Health Area
Kasungu Health District
Katema Health Centre
Katete Rural Hospital
Katimbila Health Centre
Katowo Rural Hospital
Katsekera Health Centre
Katuli Health Centre
Kaundu Health Centre
Kawale Banja La Mtsogolo Dispensary
Kawale Urban Health Centre
Kawamba Health Centre
Kawinga Dispensary
Kayembe Health Centre
Kazyozyo Maternity
Khasu Health Centre
Khola Health Centre
Khombedza Health Centre
Khondowe Health Centre
Khongoni Health Centre
Khonjeni Health Centre
Khosolo Health Centre
Khuwi Health Centre
Koche Health Centre
Kochilira Rural Hospital
KTFT Dispensary (Mziza)
Kukalanga Dispensary
Kunenekude Health Centre
Kwitanda Health Centre
Lakeview Health Centre
Lambulira Health Centre
Lemwe Health Centre
Lengwe Dispensary
Lifuwu Dispensary
Likangala Health Centre
Likoma District Health Office
Likoma Health Area
Likoma Health District
Likuni Hospital
Lilongwe Bottom Hospital
Lilongwe Central Hospital
Lilongwe District Health Office
Lilongwe Health Area
Lilongwe Health District
Limbe Health Centre
Linyangwa Health Centre
Lirangwe Health Centre
Lisungwi Health Centre
Liuzi Health Centre
Liwaladzi Health Centre
Lizulu Health Centre
Lobi Health Centre
Ludzi St Josephs Health Centre
Lugola Health Centre
Lujeri Health Centre
Lulanga Health Centre
Lulwe Health Centre
Lumbadzi Health Centre
Lundu Health Centre
Lungwena Health Centre
Lunjika Health Centre
Lupembe Health Centre
Luvwere Dispensary
Luwalika Health Centre
Luwani Health Centre
Luwawa Health Centre
Luwerezi Health Centre
Luwuchi Health Centre
Luzi Health Centre
Lwazi Dispensary
Lwezga Health Centre
Mabili Health Centre
Machinga District Health Office
Machinga District Hospital
Machinga Health Area
Machinga Health Centre
Machinga Health District
Madede Health Centre
Madisi Hospital
Madziabango Health Centre
Mafco Health Centre
Maganga Health Centre
Magareta Health Centre
Magomero Health Centre
Makanjira Health Centre
Makapwa Health Centre
Makata Dispensary
Makhanga Health Centre
Makhwira Health Centre
Makiyoni Health Centre
Makwapala Health Centre
Malamulo Hospital
Malawi (National government)
Malawi Zone
Malembo Health Centre
Malembo Health Centre (Lilongwe)
Malidadi Health Centre
Malingunde Health Centre
Maloa Dispensary
Malombe Health Centre
Malomo Health Centre
Maluwa Health Centre
Mangamba Dispensary
Mangochi District Health Office
Mangochi District Hospital
Mangochi Health Area
Mangochi Health District
Mangunda Maternity
Manjawira Maternity
Manyamula Health Centre
Maonde Health Centre
Mapanga Maternity
Maperera Health Centre
Masasa Dispensary
Mase Health Centre
Masenjere Health Centre
Matanda Dispensary
Matandani Health Centre
Matapila Health Centre
Matawale Urban Health Centre
Matiki Health Centre
Matiya Health Centre
Matope Health Centre
Matuli Dispensary
Matumba Health Centre
Mauwa Health Centre
Mauwa Maternity
Mayaka Health Centre
Mayani Health Centre
Mbabvi Health Centre
Mbalachanda Health Centre
Mbalanguzi Dispensary
Mbangombe 1 Health Centre
Mbangombe 2 Health Centre
Mbenje Health Centre
Mbera Health Centre
Mbingwa Health Centre
Mbiza Health Centre
Mbonechera Dispensary
Mbulumbudzi Health Centre
Mbulumbudzi Maternity
Mbwatalika Health Centre
Mchacha Dispensary
Mchinji District Health Office
Mchinji District Hospital
Mchinji Health Area
Mchinji Health District
Mchoka Health Centre
Mdeka Health Centre
Mfera Health Centre
Mhalaunda Health Centre
Mhuju Rural Hospital
Migowi Health Centre
Mikolongwe Health Centre
Mikondo Dispensary
Mikundi Health Centre
Milepa Health Centre
Milonde Health Centre
Mimosa Dispensary
Mingongo Health Centre
Misamvu Dispensary
Misomali Health Centre
Misuku Health Centre
Mitsidi Dispensary
Mitundu Rural Hospital
Mkanda Health Centre
Mkango Dispensary
Mkhota R Growth Health Centre
Mkhuzi Health Centre
Mkhwayi Health Centre
Mkoma Health Centre
Mkumaniza Health Centre
Mkumba Health Centre
Mkwepere Dispensary
Mlale Hospital
Mlambe Hospital
Mlanda Health Centre
Mlangali Dispensary
Mlangeni Health Centre
Mlangeni Police Health Centre
Mlodza SDA Dispensary
Mlolo Dispensary
Mlomba Dispensary
Mlowe Health Centre
Monkey-Bay Health Centre
Mpala Health Centre
Mpamantha Dispensary
Mpamba Health Centre
Mpasa Health Centre
Mpata Health Centre
Mpemba Health Centre
Mphathi Health Centre
Mphepozinai Dispensary
Mpherembe Health Centre
Mpherere Health Centre
Mphopha Health Centre
Mphunzi Health Centre
Mpiri Health Centre
Mpondas Health Centre
Mponela Rural Hospital
Mposa Health Centre
Msakambewa Health Centre
Msenjere Health Centre
Msese Health Centre
Mtakataka Health Centre
Mtende Health Centre
Mtendere Health Centre
Mtengowanthenga Hospital
Mtenthera Health Centre
Mtimabii Health Centre
Mtonda Health Centre
Mtosa Health Centre
Mtunthama Health Centre
Mtwalo Health Centre
Mua Health Centre
Mulanje District Health Office
Mulanje District Hospital
Mulanje Health Area
Mulanje Health District
Mulanje Mission Hospital
Mulibwanji Health Centre
Mulomba Health Centre
Muloza Health Centre
Muluma Dispensary
Municipality Assembly Dispensary
Mvera Army Camp Dispensary
Mvera Mission Health Centre
Mwanga Health Centre
Mwangala Health Centre
Mwansambo Health Centre
Mwanza District Health Office
Mwanza District Hospital
Mwanza Health Area
Mwanza Health District
Mwazisi Health Centre
Mzalangwe Health Centre
Mzambazi Rural Hospital
Mzandu Health Centre
Mzenga Health Centre
Mzimba District Health Office
Mzimba District Hospital
Mzimba Health Area
Mzimba Health District
Mzokoto Health Centre
Mzuzu Central Hospital
Mzuzu Urban Health Centre
Nakalanzi Health Centre
Nalunga Mafika Health Centre
Namadzi Health Centre
Namalaka Health Centre
Namandanje Health Centre
Namanja Health Centre
Namanolo Health Centre
Namasalima Health Centre (Mulanje)
Namasalima Health Centre (Zomba)
Nambazo Health Centre
Nambuma Health Centre
Namikango Health Centre
Namikoko Dispensary
Namisu Dispensary
Namitambo Health Centre
Namizana Dispensary
Namphungo Health Centre
Namulenga Health Centre
Namwera Health Centre
Nancholi Dispensary
Nangalamu Health Centre
Nankhwali Health Centre
Nankumba Health Centre
Naphimba Health Centre
Nasawa Health Centre
Nathenje Health Centre
Nayinunje Health Centre
Nayuchi Health Centre
Ndakwela Health Centre
Ndamera Health Centre
Ndaula Health Centre
Ndinda Dispensary
Ndirande Urban Health Centre
Ndunde Health Centre
Neno Health Centre
Neno Parish Health Centre
New Statehouse Dispensary
Newa / Mpasazi Health Centre
Ngabu Rural Hospital
Ngala Health Centre
Ngana Health Centre
Ngapani Health Centre
Ngodzi Health Centre
Ngokwe Health Centre
Ngoni Health Centre
Nguludi St Josephs Hospital
Ngwelero Health Centre
Njuyu Health Centre
Nkalo Health Centre
Nkasala Health Centre
Nkhamenya Hospital
Nkhande Dispensary
Nkhata Bay District Health Office
Nkhata Bay District Hospital
Nkhata Bay Health Area
Nkhata Bay Health District
Nkhataombere Maternity
Nkhoma Hospital
Nkhorongo Health Centre
Nkhotakota District Health Office
Nkhotakota District Hospital
Nkhotakota Health Area
Nkhotakota Health District
Nkhulambe Health Centre
Nkhunga Health Centre
Nkhuyukuyu Health Centre
Nkhwazi Health Centre
Nkope Health Centre
Nkula Health Centre
Nsabwe Dispensary
Nsambe Sda Health Centre
Nsanama Health Centre
Nsanje District Health Office
Nsanje District Hospital
Nsanje Health Area
Nsanje Health District
Nsaru Health Centre
Nsipe Health Centre
Nsiyaludzu Health Centre
Ntaja Health Centre
Ntcheu District Health Office
Ntcheu District Hospital
Ntcheu Health Area
Ntcheu Health District
Ntchisi District Health Office
Ntchisi District Hospital
Ntchisi Health Area
Ntchisi Health District
Nthalire Health Centre
Nthenje Dispensary
Nthondo Health Centre (Lilongwe)
Nthondo Health Centre (Ntchisi)
Nthungwa Health Centre
Nyambi Health Centre
Nyamithuthu Health Centre
Nyungwe Health Centre
Nzama Health Centre
Ofesi Dispensary
Old Maula Court Health Centre
Phalombe Dispensary
Phalombe District Health Office
Phalombe Health Area
Phalombe Health District
Phalombe Mission Hospital
Phalula Health Centre
Phimbi Health Centre
Phirilongwe Health Centre
Phokera Dispensary
Pim Health Centre
Pirimiti Health Centre
Police (Area 30) Dispensary
Police College Dispensary
Police Hospital
Queen Elizabeth Central Hospital
Raiply Dispensary
Ruarwe Dispensary
Rumphi District Health Office
Rumphi District Hospital
Rumphi Health Area
Rumphi Health District
Salima District Health Office
Salima District Hospital
Salima Health Area
Salima Health District
Sangilo Health Centre
Sankhulani Health Centre
Santhe Health Centre
Senga Bay Baptist Dispensary
Senzani Health Centre
Sharpevale Maternity
Simlemba Health Centre
Sinyala Health Centre
Sister Teleza Health Centre
Soche Dispensary
Soche Maternity
Sorgin Health Centre
South Lunzu Dispensary
South Lunzu Health Centre
St Annes Health Centre
St Annes Hospital
St Gabriels Hospital
St Johns Mzuzu Hospital
St Johns of God Mental Hospital
St Josephs Mitengo Health Centre
St Lukes Hospital
St Marthas Health Centre
St Martin Hospital
St Martins Health Centre
St Martins Molere Health Centre
St Montfort Hospital
St Patricks Rumphi Health Centre
St Peters (Likoma) Rural Hospital
St Peters Hospital
State House Dispensary
SUCOMA Health Centre (Illovo)
Sukasanje Health Centre
Tcharo Dispensary
Tembwe Dispensary
Tengani Health Centre
Thambani Health Centre
Thavite Health Centre
Thekerani Rural Hospital
Thembe Dispensary
Thomas Health Centre
Thondwe Dispensary
Thonje Health Centre
Thuchila Health Centre
Thunduwike Health Centre
Thyolo District Health Office
Thyolo District Hospital
Thyolo Health Area
Thyolo Health District
Trinity - Fatima Hospital
Tsangano Dispensary
Tsoyo Maternity
Tulonkhondo Health Centre
Ukwe Health Centre
Ulongwe Health Centre
Usisya Health Centre
Utale 1 Health Centre
Utale 2 Health Centre
Vibangalala Dispensary
Wenya Health Centre
Wiliro Health Centre
Wimbe Health Centre
Zingwangwa Urban Health Centre
Zoa Dispensary
Zoa Maternity
Zomba Central Hospital
Zomba District Health Office
Zomba Forestry Dispensary
Zomba Health Area
Zomba Health District
Zomba Mental Hospital
Zomba Prison Dispensary
Kamuzu Central Hospital
Moyo Clinic
Dalitso Clinic
Martin Preuss Centre
Lighthouse
Lighthouse HTC
Partners in Hope
MACRO Blantyre
Lepra
Adventist Hospital
Tiyanjane
Napham
Mwaiwathu Private Hospital
EOF
    return facilities.split("\n")
  end

  @@location_list = initialize_location_list()
  @@health_facilities = initialize_health_facilities()

end

### Original SQL Definition for location #### 
#   `location_id` int(11) NOT NULL auto_increment,
#   `name` varchar(255) NOT NULL default '',
#   `description` varchar(255) default NULL,
#   `address1` varchar(50) default NULL,
#   `address2` varchar(50) default NULL,
#   `city_village` varchar(50) default NULL,
#   `state_province` varchar(50) default NULL,
#   `postal_code` varchar(50) default NULL,
#   `country` varchar(50) default NULL,
#   `latitude` varchar(50) default NULL,
#   `longitude` varchar(50) default NULL,
#   `parent_location_id` int(11) default NULL,
#   `creator` int(11) NOT NULL default '0',
#   `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
#   PRIMARY KEY  (`location_id`),
#   KEY `user_who_created_location` (`creator`),
#   CONSTRAINT `user_who_created_location` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)





