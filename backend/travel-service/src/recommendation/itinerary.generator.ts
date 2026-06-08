export class ItineraryGenerator {
  // Dummy data aktivitas per kota per jumlah hari
  private readonly cityPlans: Record<string, Record<number, { day: number; activities: string[] }[]>> = {
    jakarta: {
      3: [
        {
          day: 1,
          activities: [
            'Kunjungi Monas (Monumen Nasional) & Museum Sejarah Jakarta',
            'Jelajahi Kota Tua & Taman Fatahillah',
            'Makan malam di Kawasan Kuliner Sabang',
          ],
        },
        {
          day: 2,
          activities: [
            'Wisata budaya di Taman Mini Indonesia Indah (TMII)',
            'Belanja dan hangout di Mall Grand Indonesia',
            'Nikmati sunset di Pantai Ancol',
          ],
        },
        {
          day: 3,
          activities: [
            'Pagi di Kepulauan Seribu (day trip via dermaga Muara Angke)',
            'Snorkeling & menikmati laut Jakarta',
            'Perjalanan pulang & oleh-oleh di PIK Avenue',
          ],
        },
      ],
      5: [
        {
          day: 1,
          activities: [
            'Kunjungi Monas & Museum Nasional Indonesia',
            'Jelajahi Kota Tua & Cafe Batavia',
            'Makan malam di Jalan Sabang',
          ],
        },
        {
          day: 2,
          activities: [
            'Wisata budaya di Taman Mini Indonesia Indah',
            'Museum Purna Bhakti Pertiwi',
            'Belanja di Mall of Indonesia',
          ],
        },
        {
          day: 3,
          activities: [
            'Day trip ke Kepulauan Seribu',
            'Snorkeling di Pulau Tidung',
            'Sunset BBQ di tepi pantai',
          ],
        },
        {
          day: 4,
          activities: [
            'Wisata kuliner di Setu Babakan (Kampung Betawi)',
            'Kebun Binatang Ragunan',
            'Nongkrong malam di kawasan SCBD',
          ],
        },
        {
          day: 5,
          activities: [
            'Pagi di Pasar Santa & area vintage Kemang',
            'Lunch di kawasan Blok M',
            'Perjalanan pulang & oleh-oleh khas Betawi',
          ],
        },
      ],
      7: [
        {
          day: 1,
          activities: [
            'Kunjungi Monas & Museum Nasional Indonesia',
            'Jelajahi Kota Tua & Taman Fatahillah',
            'Makan malam di kawasan Sabang',
          ],
        },
        {
          day: 2,
          activities: [
            'Taman Mini Indonesia Indah (TMII)',
            'Museum Transportasi & Bahari',
            'Malam di Ancol Dreamland',
          ],
        },
        {
          day: 3,
          activities: [
            'Day trip Kepulauan Seribu – Pulau Tidung',
            'Snorkeling & sepeda pantai',
            'Sunset di dermaga',
          ],
        },
        {
          day: 4,
          activities: [
            'Wisata kuliner Setu Babakan & Kampung Betawi',
            'Kebun Binatang Ragunan',
            'Evening walk di Kemang',
          ],
        },
        {
          day: 5,
          activities: [
            'Belanja di Pasar Baru & Tanah Abang',
            'Makan siang di Restoran Batavia Kota Tua',
            'Malam di Dufan Ancol',
          ],
        },
        {
          day: 6,
          activities: [
            'Wisata religi di Masjid Istiqlal & Gereja Katedral',
            'Museum Bank Indonesia',
            'Menikmati Jazz & kuliner malam PIK2',
          ],
        },
        {
          day: 7,
          activities: [
            'Pagi santai di Hutan Kota Srengseng',
            'Berbelanja oleh-oleh khas Jakarta',
            'Perjalanan pulang',
          ],
        },
      ],
    },

    bandung: {
      3: [
        {
          day: 1,
          activities: [
            'Kawah Putih – danau vulkanik berwarna putih kehijauan',
            'Mampir ke Floating Market Lembang',
            'Makan malam & belanja di Cihampelas Walk',
          ],
        },
        {
          day: 2,
          activities: [
            'Pagi di Tangkuban Perahu – kawah aktif yang ikonik',
            'Lunch di Kampung Daun',
            'Sore di Jalan Braga & Asia Afrika',
          ],
        },
        {
          day: 3,
          activities: [
            'Sarapan di warung kopi Kota Tua Bandung',
            'Belanja di Factory Outlet Jl. Riau',
            'Perjalanan pulang sambil beli oleh-oleh',
          ],
        },
      ],
      5: [
        {
          day: 1,
          activities: [
            'Kawah Putih Ciwidey',
            'Kebun Strawberry Ciwidey',
            'Makan malam di Floating Market Lembang',
          ],
        },
        {
          day: 2,
          activities: [
            'Tangkuban Perahu',
            'Farm House Lembang',
            'Sore di Jalan Braga',
          ],
        },
        {
          day: 3,
          activities: [
            'Wisata alam Dusun Bambu Lembang',
            'Glamping di sekitar danau',
            'BBQ & bonfire malam',
          ],
        },
        {
          day: 4,
          activities: [
            'Saung Angklung Udjo – pertunjukan budaya Sunda',
            'Belanja batik & kain Sunda',
            'Malam kuliner di Pasar Baru',
          ],
        },
        {
          day: 5,
          activities: [
            'Museum Geologi Bandung',
            'Belanja Factory Outlet Jl. Riau',
            'Perjalanan pulang & oleh-oleh',
          ],
        },
      ],
      7: [
        {
          day: 1,
          activities: [
            'Kawah Putih Ciwidey',
            'Situ Patengan',
            'Kebun Teh Ciwidey',
          ],
        },
        {
          day: 2,
          activities: [
            'Tangkuban Perahu',
            'Farm House Lembang',
            'Floating Market Lembang',
          ],
        },
        {
          day: 3,
          activities: [
            'Dusun Bambu – hiking & glamping',
            'Curug Cimahi (Air Terjun)',
            'Sore santai di alam terbuka',
          ],
        },
        {
          day: 4,
          activities: [
            'Saung Angklung Udjo',
            'Sentra Rajutan Binong Jati',
            'Malam di Alun-alun Bandung',
          ],
        },
        {
          day: 5,
          activities: [
            'Trans Studio Bandung (theme park)',
            'Makan siang di food court Trans Studio',
            'Nongkrong malam di kawasan Dago',
          ],
        },
        {
          day: 6,
          activities: [
            'Museum Geologi & Museum Sri Baduga',
            'Jalan Asia Afrika & Braga',
            'Kuliner malam Batagor & Siomay khas Bandung',
          ],
        },
        {
          day: 7,
          activities: [
            'Belanja Factory Outlet & oleh-oleh',
            'Kopi pagi di Kopi Anjis',
            'Perjalanan pulang',
          ],
        },
      ],
    },

    yogyakarta: {
      3: [
        {
          day: 1,
          activities: [
            'Candi Borobudur – UNESCO World Heritage saat matahari terbit',
            'Makan siang di sekitar Borobudur',
            'Sore di Candi Prambanan – kompleks candi Hindu terbesar',
          ],
        },
        {
          day: 2,
          activities: [
            'Pagi di Keraton Yogyakarta & Museum Batik',
            'Jalan Malioboro – belanja & makan gudeg',
            'Malam di Alun-alun Kidul (masuk dua pohon beringin)',
          ],
        },
        {
          day: 3,
          activities: [
            'Sarapan gudeg khas Jogja',
            'Belanja batik & perak Kotagede',
            'Perjalanan pulang & oleh-oleh bakpia',
          ],
        },
      ],
      5: [
        {
          day: 1,
          activities: [
            'Candi Borobudur saat matahari terbit',
            'Candi Mendut & Pawon',
            'Makan siang khas Magelang',
          ],
        },
        {
          day: 2,
          activities: [
            'Candi Prambanan & Candi Sewu',
            'Museum Affandi',
            'Keraton Yogyakarta malam',
          ],
        },
        {
          day: 3,
          activities: [
            'Jalan Malioboro & Pasar Beringharjo',
            'Makan siang gudeg Yu Djum',
            'Malam pertunjukan Wayang Kulit',
          ],
        },
        {
          day: 4,
          activities: [
            'Petualangan di Goa Jomblang (caving dengan sinar surya)',
            'Pantai Parangtritis & Bukit Paralayang',
            'Sunset di Parangkusumo',
          ],
        },
        {
          day: 5,
          activities: [
            'Perak Kotagede & Batik Kraton',
            'Museum Sonobudoyo',
            'Perjalanan pulang & oleh-oleh bakpia',
          ],
        },
      ],
      7: [
        {
          day: 1,
          activities: [
            'Candi Borobudur saat matahari terbit',
            'Candi Mendut',
            'Check-in dan istirahat',
          ],
        },
        {
          day: 2,
          activities: [
            'Candi Prambanan & Ratu Boko',
            'Pentas Ramayana Ballet sore hari',
            'Makan malam di Jalan Malioboro',
          ],
        },
        {
          day: 3,
          activities: [
            'Keraton Yogyakarta & Museum Batik',
            'Pasar Beringharjo',
            'Alun-alun Kidul malam',
          ],
        },
        {
          day: 4,
          activities: [
            'Goa Jomblang – adventure caving',
            'Goa Pindul – cave tubing',
            'Menikmati sungai bawah tanah',
          ],
        },
        {
          day: 5,
          activities: [
            'Pantai Indrayanti & Pantai Drini',
            'Pantai Siung – rock climbing spot',
            'Sunset di Pantai Wediombo',
          ],
        },
        {
          day: 6,
          activities: [
            'Candi Sambisari & Candi Kalasan',
            'Museum Affandi',
            'Malam kuliner di Malioboro',
          ],
        },
        {
          day: 7,
          activities: [
            'Belanja perak Kotagede & batik',
            'Sarapan gudeg terakhir',
            'Perjalanan pulang & bakpia oleh-oleh',
          ],
        },
      ],
    },

    bali: {
      3: [
        {
          day: 1,
          activities: [
            'Pura Tanah Lot saat sunset yang ikonik',
            'Belanja & kulineran di Seminyak Street',
            'Makan malam di tepi pantai Seminyak',
          ],
        },
        {
          day: 2,
          activities: [
            'Pagi di Pura Uluwatu & pertunjukan Kecak Dance',
            'Pantai Padang Padang & Dreamland Beach',
            'Dinner di Single Fin Uluwatu',
          ],
        },
        {
          day: 3,
          activities: [
            'Sarapan di warung lokal Kuta',
            'Berbelanja oleh-oleh di Pasar Seni Sukawati',
            'Perjalanan pulang',
          ],
        },
      ],
      5: [
        {
          day: 1,
          activities: [
            'Pura Tanah Lot & sunset',
            'Belanja di Seminyak Village',
            'Malam di Beach Club Finns',
          ],
        },
        {
          day: 2,
          activities: [
            'Pura Uluwatu & Kecak Dance',
            'Pantai Bingin & Padang Padang',
            'Dinner romantis di Jimbaran Bay',
          ],
        },
        {
          day: 3,
          activities: [
            'Ubud Monkey Forest',
            'Tegalalang Rice Terrace',
            'Makan siang di Warung Babi Guling Ibu Oka',
          ],
        },
        {
          day: 4,
          activities: [
            'Sanur Beach – sunrise pagi',
            'Snorkeling di Nusa Lembongan (day trip)',
            'Malam di Kuta Beach',
          ],
        },
        {
          day: 5,
          activities: [
            'Pura Besakih – Pura terbesar di Bali',
            'Pasar Seni Sukawati',
            'Perjalanan pulang & oleh-oleh',
          ],
        },
      ],
      7: [
        {
          day: 1,
          activities: [
            'Pura Tanah Lot & sunset',
            'Seminyak & Petitenget',
            'Malam di Potato Head Beach Club',
          ],
        },
        {
          day: 2,
          activities: [
            'Pura Uluwatu & Kecak Dance',
            'Pantai Padang Padang',
            'Dinner di Jimbaran Seafood',
          ],
        },
        {
          day: 3,
          activities: [
            'Ubud – Monkey Forest',
            'Tegalalang Rice Terrace',
            'Kopi Luwak experience',
          ],
        },
        {
          day: 4,
          activities: [
            'Nusa Penida – Kelingking Beach',
            'Angel Billabong & Broken Beach',
            'Crystal Bay snorkeling',
          ],
        },
        {
          day: 5,
          activities: [
            'Sanur Beach sunrise',
            'Nusa Lembongan snorkeling',
            'Devil Tears & Dream Beach',
          ],
        },
        {
          day: 6,
          activities: [
            'Pura Besakih (Mother Temple)',
            'Danau Batur & Gunung Batur trekking',
            'Pemandian air panas alami Toya Bungkah',
          ],
        },
        {
          day: 7,
          activities: [
            'Belanja di Pasar Seni Sukawati',
            'Kuta – oleh-oleh & SPA terakhir',
            'Perjalanan pulang',
          ],
        },
      ],
    },

    'labuan bajo': {
      3: [
        {
          day: 1,
          activities: [
            'Pulau Komodo – trekking melihat komodo liar',
            'Pantai Pink (Pink Beach) – snorkeling di terumbu karang',
            'Sunset di Padar Island viewpoint',
          ],
        },
        {
          day: 2,
          activities: [
            'Manta Point – berenang bersama pari manta',
            'Taka Makassar – sandbar putih di tengah laut',
            'Makan malam di Kampung Ujung Labuan Bajo',
          ],
        },
        {
          day: 3,
          activities: [
            'Puncak Waringin – sunrise dengan pemandangan kota Labuan Bajo',
            'Waterfront Marina & Pelabuhan Labuan Bajo',
            'Perjalanan pulang via Bandara Komodo',
          ],
        },
      ],
      5: [
        {
          day: 1,
          activities: [
            'Tiba di Labuan Bajo – check in & istirahat',
            'Puncak Waringin sore hari',
            'Makan malam seafood di waterfront',
          ],
        },
        {
          day: 2,
          activities: [
            'Pulau Komodo – trekking & melihat komodo',
            'Pantai Pink – snorkeling',
            'Kembali ke Labuan Bajo',
          ],
        },
        {
          day: 3,
          activities: [
            'Padar Island – trekking & pemandangan 360°',
            'Manta Point – renang dengan manta',
            'Taka Makassar sandbar',
          ],
        },
        {
          day: 4,
          activities: [
            'Pulau Bidadari – snorkeling & relaxing',
            'Goa Batu Cermin – gua cermin unik',
            'Kuliner lokal Labuan Bajo malam',
          ],
        },
        {
          day: 5,
          activities: [
            'Belanja oleh-oleh khas Flores (kain songket, tenun)',
            'Exotic Komodo Souvenir Shop',
            'Perjalanan pulang',
          ],
        },
      ],
      7: [
        {
          day: 1,
          activities: [
            'Tiba & check in hotel',
            'Makan siang di Kampung Ujung',
            'Puncak Waringin sunset',
          ],
        },
        {
          day: 2,
          activities: [
            'Pulau Komodo – trekking',
            'Snorkeling di sekitar Pulau Komodo',
            'Kembali & makan malam di Atlantis on The Rock',
          ],
        },
        {
          day: 3,
          activities: [
            'Padar Island – trekking puncak 360°',
            'Pantai Pink – snorkeling',
            'Taka Makassar – sunset di sandbar',
          ],
        },
        {
          day: 4,
          activities: [
            'Manta Point – diving/snorkeling',
            'Pulau Rinca – melihat komodo kedua',
            'Makan malam di Le Pirate Restaurant',
          ],
        },
        {
          day: 5,
          activities: [
            'Pulau Bidadari & Pulau Mesa',
            'Goa Batu Cermin',
            'Amelia Hill sunset',
          ],
        },
        {
          day: 6,
          activities: [
            'Sylvia Hill & viewpoint kota',
            'Sei Sapi Lejong – kuliner lokal',
            'Wisata malam Labuan Bajo waterfront',
          ],
        },
        {
          day: 7,
          activities: [
            'Belanja kain tenun Flores & songket',
            'Sarapan terakhir di Carpenter Café & Roastery',
            'Perjalanan pulang via Bandara Komodo',
          ],
        },
      ],
    },

    lombok: {
      3: [
        {
          day: 1,
          activities: [
            'Gili Trawangan – bersepeda keliling gili & snorkeling',
            'Gili Air – berenang di air jernih',
            'Sunset di tepi pantai Gili Trawangan',
          ],
        },
        {
          day: 2,
          activities: [
            'Pantai Selong Belanak – salah satu pantai terbaik Lombok',
            'Surfing lesson di Pantai Mawun',
            'Pantai Kuta Lombok – sunset romantis',
          ],
        },
        {
          day: 3,
          activities: [
            'Sarapan di Kuta & santai di pantai',
            'Belanja oleh-oleh & kain tenun Sukarara',
            'Perjalanan pulang via Bandara Internasional Lombok',
          ],
        },
      ],
      5: [
        {
          day: 1,
          activities: [
            'Tiba & check in',
            'Pura Batu Bolong – pura Hindu di tepi pantai',
            'Makan malam di Senggigi Beach',
          ],
        },
        {
          day: 2,
          activities: [
            'Gili Trawangan – snorkeling & bersepeda',
            'Gili Meno & Gili Air',
            'Sunset party di Gili Trawangan',
          ],
        },
        {
          day: 3,
          activities: [
            'Pantai Selong Belanak',
            'Pantai Mawun – surfing & berenang',
            'Pantai Kuta Lombok',
          ],
        },
        {
          day: 4,
          activities: [
            'Air Terjun Benang Stokel & Benang Kelambu',
            'Desa Sade – desa tradisional Sasak',
            'Makan malam di Mataram',
          ],
        },
        {
          day: 5,
          activities: [
            'Belanja kain tenun Sukarara',
            'Pasar Cakranegara & oleh-oleh',
            'Perjalanan pulang',
          ],
        },
      ],
      7: [
        {
          day: 1,
          activities: [
            'Tiba di Lombok',
            'Pura Batu Bolong',
            'Senggigi Beach & makan malam',
          ],
        },
        {
          day: 2,
          activities: [
            'Gili Trawangan – snorkeling & diving',
            'Gili Air – berenang & relaxing',
            'Sunset di dermaga Gili',
          ],
        },
        {
          day: 3,
          activities: [
            'Pantai Selong Belanak',
            'Pantai Mawun & surfing',
            'Pantai Kuta Lombok',
          ],
        },
        {
          day: 4,
          activities: [
            'Rinjani Basecamp – trekking hari pertama',
            'Pemandangan Danau Segara Anak',
            'Camp & bintang malam',
          ],
        },
        {
          day: 5,
          activities: [
            'Trekking summit Gunung Rinjani',
            'Pemandangan 360° dari puncak (3726 mdpl)',
            'Turun ke basecamp & istirahat',
          ],
        },
        {
          day: 6,
          activities: [
            'Air Terjun Benang Stokel & Kelambu',
            'Desa Sade – tenun tradisional Sasak',
            'Tetebatu – suasana pedesaan kaki Rinjani',
          ],
        },
        {
          day: 7,
          activities: [
            'Sembalun – hamparan savana indah',
            'Belanja kain tenun Sukarara & oleh-oleh',
            'Perjalanan pulang',
          ],
        },
      ],
    },

    sumba: {
      3: [
        {
          day: 1,
          activities: [
            'Bukit Tenau – menikmati sunset savana yang syahdu',
            'Makan malam di Kafe lokal Waingapu',
          ],
        },
        {
          day: 2,
          activities: [
            'Air Terjun Waimarang – berenang di kolam alami toska',
            'Pantai Walakiri – sunset pohon menari (dancing trees)',
          ],
        },
        {
          day: 3,
          activities: [
            'Kampung Adat Prailiu – belanja kain ikat tenun khas Sumba',
            'Perjalanan pulang via Bandara Umbu Mehang Kunda (Waingapu)',
          ],
        },
      ],
      5: [
        {
          day: 1,
          activities: [
            'Tiba di Waingapu – check-in & istirahat',
            'Sunset di Bukit Persaudaraan',
            'Makan malam kuliner lokal',
          ],
        },
        {
          day: 2,
          activities: [
            'Air Terjun Waimarang',
            'Pantai Walakiri – menikmati sunset ikonik',
          ],
        },
        {
          day: 3,
          activities: [
            'Air Terjun Tanggedu – Grand Canyon Sumba',
            'Savana Puru Kambera – melihat kuda liar Sumba',
          ],
        },
        {
          day: 4,
          activities: [
            'Perjalanan ke Sumba Barat – Waikabubak',
            'Air Terjun Lapopu',
            'Kampung Adat Prai Ijing',
          ],
        },
        {
          day: 5,
          activities: [
            'Laguna Weekuri – kolam air asin alami',
            'Pantai Mandorak',
            'Perjalanan pulang via Bandara Tambolaka',
          ],
        },
      ],
      7: [
        {
          day: 1,
          activities: [
            'Tiba di Waingapu – Bukit Persaudaraan sunset',
            'Makan malam seafood di pelabuhan',
          ],
        },
        {
          day: 2,
          activities: [
            'Air Terjun Waimarang',
            'Pantai Walakiri – sunset mangrove menari',
          ],
        },
        {
          day: 3,
          activities: [
            'Air Terjun Tanggedu',
            'Savana Puru Kambera',
            'Sore santai di pantai',
          ],
        },
        {
          day: 4,
          activities: [
            'Perjalanan ke Sumba Barat',
            'Kampung Adat Prai Ijing',
            'Sore di Bukit Lendongara',
          ],
        },
        {
          day: 5,
          activities: [
            'Laguna Weekuri – berenang air asin jernih',
            'Pantai Mandorak',
            'Menikmati matahari terbenam',
          ],
        },
        {
          day: 6,
          activities: [
            'Pantai Bawana – tebing bolong ikonik',
            'Kampung Adat Ratenggaro – rumah adat menara tinggi',
          ],
        },
        {
          day: 7,
          activities: [
            'Pagi santai di Nihiwatu',
            'Belanja oleh-oleh ikat tenun Sumba',
            'Perjalanan pulang via Bandara Tambolaka',
          ],
        },
      ],
    },

    'raja ampat': {
      3: [
        {
          day: 1,
          activities: [
            'Tiba di Waisai – check-in homestay',
            'Sore santai di Pantai Friwen',
            'Makan malam di tepi pantai',
          ],
        },
        {
          day: 2,
          activities: [
            'Piaynemo – mendaki puncak gugusan karst ikonik',
            'Sauwandarek – snorkeling bersama penyu',
            'Sunset di Teluk Kabui',
          ],
        },
        {
          day: 3,
          activities: [
            'Pasir Timbul – pulau pasir putih di tengah laut',
            'Kembali ke Sorong via kapal cepat',
            'Perjalanan pulang',
          ],
        },
      ],
      5: [
        {
          day: 1,
          activities: [
            'Tiba di Sorong – kapal cepat ke Waisai',
            'Check-in resort/homestay',
            'Sunset di Friwen Beach',
          ],
        },
        {
          day: 2,
          activities: [
            'Puncak Piaynemo viewpoint',
            'Snorkeling di Friwen Wall',
            'Teluk Kabui & Pensil Rock',
          ],
        },
        {
          day: 3,
          activities: [
            'Day trip ke Wayag – mendaki puncak karst utama',
            'Berenang bersama anak hiu di Laguna Wayag',
            'BBQ di tepi pantai',
          ],
        },
        {
          day: 4,
          activities: [
            'Desa Wisata Arborek',
            'Snorkeling di Manta Sandy – melihat pari manta',
            'Yenbuba Jetty snorkeling',
          ],
        },
        {
          day: 5,
          activities: [
            'Pasir Timbul',
            'Belanja kerajinan tangan noken & patung Papua',
            'Ferry kembali ke Sorong',
          ],
        },
      ],
      7: [
        {
          day: 1,
          activities: [
            'Tiba di Sorong – transfer ke resort/homestay',
            'Welcome dinner & pengenalan konservasi',
          ],
        },
        {
          day: 2,
          activities: [
            'Puncak Piaynemo – view bukit karst',
            'Snorkeling Friwen Wall & Sauwandarek',
          ],
        },
        {
          day: 3,
          activities: [
            'Wayag Island – trekking puncak tebing karst terjal',
            'Swim with baby sharks',
            'BBQ ikan segar di pantai',
          ],
        },
        {
          day: 4,
          activities: [
            'Desa Arborek – kerajinan topi pari manta',
            'Manta Sandy snorkeling',
            'Sunset cruise di Selat Dampier',
          ],
        },
        {
          day: 5,
          activities: [
            'Yenbuba Jetty marine life exploration',
            'Cape Kri – snorkeling terumbu karang terkaya dunia',
          ],
        },
        {
          day: 6,
          activities: [
            'Kali Biru (Blue River) – petualangan ke hutan pedalaman',
            'Air Terjun Pulau Batanta',
          ],
        },
        {
          day: 7,
          activities: [
            'Pasir Timbul sunrise',
            'Oleh-oleh khas Papua di Sorong',
            'Penerbangan pulang',
          ],
        },
      ],
    },
  };

  generate(city: string, days: number): { city: string; days: number; tripType: string; plan: { day: number; activities: string[] }[] } {
    // Tentukan trip type
    const tripType = days <= 3 ? 'Compact Trip' : days <= 5 ? 'Balanced Trip' : 'Slow & Explore Trip';

    // Normalisasi nama kota
    const cityKey = city.toLowerCase().trim();

    // Cari kunci kota yang cocok (partial match)
    const matchedKey = Object.keys(this.cityPlans).find(k =>
      cityKey.includes(k) || k.includes(cityKey),
    );

    // Tentukan jumlah hari yang tersedia (3, 5, atau 7)
    let targetDays: number;
    if (days <= 3) {
      targetDays = 3;
    } else if (days <= 5) {
      targetDays = 5;
    } else {
      targetDays = 7;
    }

    // Ambil plan dari data, atau gunakan generic plan
    let plan: { day: number; activities: string[] }[];

    if (matchedKey && this.cityPlans[matchedKey][targetDays]) {
      plan = this.cityPlans[matchedKey][targetDays];

      // Jika days diminta berbeda (misal 4 hari tapi data hanya 3 atau 5)
      if (days !== targetDays) {
        // Potong atau extend plan sesuai days yang diminta
        plan = plan.slice(0, days);
        // Jika kurang, tambahkan hari ekstra generic
        while (plan.length < days) {
          const nextDay = plan.length + 1;
          plan.push({
            day: nextDay,
            activities: [
              `Eksplorasi lokal ${city}`,
              `Mencicipi kuliner khas ${city}`,
              `Berjalan-jalan santai di sudut kota ${city}`,
            ],
          });
        }
      }
    } else {
      // Generic plan untuk kota yang belum ada di database
      plan = [];
      for (let i = 1; i <= days; i++) {
        plan.push({
          day: i,
          activities: [
            `Eksplorasi destinasi wisata utama di ${city}`,
            `Mencoba kuliner lokal khas ${city}`,
            `Evening walk di area ikonik ${city}`,
          ],
        });
      }
    }

    return {
      city,
      days,
      tripType,
      plan,
    };
  }
}