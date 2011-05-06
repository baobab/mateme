class Location < ActiveRecord::Base
  set_table_name "location"
  set_primary_key "location_id"
  has_many :obs, :foreign_key => :location_id
  has_many :patient_identifiers, :foreign_key => :location_id
  has_many :encounters, :foreign_key => :location_id
  belongs_to :parent, :foreign_key => :parent_location_id, :class_name => "Location"
  has_many :children, :foreign_key => :parent_location_id, :class_name => "Location"
  belongs_to :user, :foreign_key => :user_id
  has_many :location_tag_map, :foreign_key => :location_id

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
  
  def self.search(search_string)
      field_name = "name"
      @names = self.find_by_sql("SELECT * FROM location WHERE name LIKE '%#{search_string}%' ORDER BY name ASC").collect{|name| name.send(field_name)}

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

  @@location_list = initialize_location_list()

end
