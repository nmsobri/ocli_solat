package main

import "ocurl"
import "core:c"
import "core:os"
import "core:mem"
import "core:fmt"
import "core:time"
import "core:slice"
import "core:runtime"
import "core:encoding/json"

SIZE: uint = 0
DEFAULT_ZONE :: "PNG01"
API :: "https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat&period=month&zone="


Solat :: struct {
  PrayerTime: []struct {
    Hijri:   string `json:"hijri"`,
    Date:    string `json:"date"`,
    Day:     string `json:"day"`,
    Imsak:   string `json:"imsak"`,
    Fajr:    string `json:"fajr"`,
    Syuruk:  string `json:"syuruk"`,
    Dhuhr:   string `json:"dhuhr"`,
    Asr:     string `json:"asr"`,
    Maghrib: string `json:"maghrib"`,
    Isha:    string `json:"isha"`,
  } `json:"prayerTime"`,
  Status:     string `json:"status"`,
  ServerTime: string `json:"serverTime"`,
  PeriodType: string `json:"periodType"`,
  Lang:       string `json:"lang"`,
  Zone:       string `json:"zone"`,
  Bearing:    string `json:"bearing"`,
}


write_callback :: proc "c" (ptr: [^]byte, size, nmemb: c.size_t, data: ^rawptr) -> c.size_t {
  context = runtime.default_context()

  realsize := size * nmemb
  SIZE = realsize

  data^ = mem.resize(data^, 1, cast(int)realsize)
  mem.copy(data^, ptr, cast(int)realsize)

  // cast to multi pointer so we can index it
  _data := cast([^]byte)data^
  _data[realsize] = 0
  return realsize
}

display_help :: proc() {
  help := `
Usage of solat.exe:
  -help
        display help message
  -zone string
        select zone to display the prayer time
  -zones
        display all available zone to select
	`

  fmt.println(help)
}

display_zones :: proc() {
  zones := `
  Johor:
  JHR01 Pulau Aur dan Pulau Pemanggil
  JHR02 Johor Bahru, Kota Tinggi, Mersing, Kulai
  JHR03 Kluang, Pontian
  JHR04 Batu Pahat, Muar, Segamat, Gemas Johor, Tangkak

Kedah:
  KDH01 Kota Setar, Kubang Pasu, Pokok Sena (Daerah Kecil)
  KDH02 Kuala Muda, Yan, Pendang
  KDH03 Padang Terap, Sik
  KDH04 Baling
  KDH05 Bandar Baharu, Kulim
  KDH06 Langkawi
  KDH07 Puncak Gunung Jerai

Kelantan:
  KTN01 Bachok, Kota Bharu, Machang, Pasir Mas, Pasir Puteh, Tanah Merah, Tumpat, Kuala Krai, Mukim Chiku
  KTN02 Gua Musang (Daerah Galas Dan Bertam), Jeli, Jajahan Kecil Lojing

Melaka:
  MLK01 SELURUH NEGERI MELAKA

Negeri Sembilan:
  NGS01 Tampin, Jempol
  NGS02 Jelebu, Kuala Pilah, Rembau
  NGS03 Port Dickson, Seremban

Pahang:
  PHG01 Pulau Tioman
  PHG02 Kuantan, Pekan, Rompin, Muadzam Shah
  PHG03 Jerantut, Temerloh, Maran, Bera, Chenor, Jengka
  PHG04 Bentong, Lipis, Raub
  PHG05 Genting Sempah, Janda Baik, Bukit Tinggi
  PHG06 Cameron Highlands, Genting Higlands, Bukit Fraser

Perlis:
  PLS01 Kangar, Padang Besar, Arau

Pulau Pinang:
  PNG01 Seluruh Negeri Pulau Pinang

Perak:
  PRK01 Tapah, Slim River, Tanjung Malim
  PRK02 Kuala Kangsar, Sg. Siput , Ipoh, Batu Gajah, Kampar
  PRK03 Lenggong, Pengkalan Hulu, Grik
  PRK04 Temengor, Belum
  PRK05 Kg Gajah, Teluk Intan, Bagan Datuk, Seri Iskandar, Beruas, Parit, Lumut, Sitiawan, Pulau Pangkor
  PRK06 Selama, Taiping, Bagan Serai, Parit Buntar
  PRK07 Bukit Larut

Sabah:
  SBH01 Bahagian Sandakan (Timur), Bukit Garam, Semawang, Temanggong, Tambisan, Bandar Sandakan, Sukau
  SBH02 Beluran, Telupid, Pinangah, Terusan, Kuamut, Bahagian Sandakan (Barat)
  SBH03 Lahad Datu, Silabukan, Kunak, Sahabat, Semporna, Tungku, Bahagian Tawau  (Timur)
  SBH04 Bandar Tawau, Balong, Merotai, Kalabakan, Bahagian Tawau (Barat)
  SBH05 Kudat, Kota Marudu, Pitas, Pulau Banggi, Bahagian Kudat
  SBH06 Gunung Kinabalu
  SBH07 Kota Kinabalu, Ranau, Kota Belud, Tuaran, Penampang, Papar, Putatan, Bahagian Pantai Barat
  SBH08 Pensiangan, Keningau, Tambunan, Nabawan, Bahagian Pendalaman (Atas)
  SBH09 Beaufort, Kuala Penyu, Sipitang, Tenom, Long Pasia, Membakut, Weston, Bahagian Pendalaman (Bawah)

Selangor:
  SGR01 Gombak, Petaling, Sepang, Hulu Langat, Hulu Selangor, S.Alam
  SGR02 Kuala Selangor, Sabak Bernam
  SGR03 Klang, Kuala Langat

Sarawak:
  SWK01 Limbang, Lawas, Sundar, Trusan
  SWK02 Miri, Niah, Bekenu, Sibuti, Marudi
  SWK03 Pandan, Belaga, Suai, Tatau, Sebauh, Bintulu
  SWK04 Sibu, Mukah, Dalat, Song, Igan, Oya, Balingian, Kanowit, Kapit
  SWK05 Sarikei, Matu, Julau, Rajang, Daro, Bintangor, Belawai
  SWK06 Lubok Antu, Sri Aman, Roban, Debak, Kabong, Lingga, Engkelili, Betong, Spaoh, Pusa, Saratok
  SWK07 Serian, Simunjan, Samarahan, Sebuyau, Meludam
  SWK08 Kuching, Bau, Lundu, Sematan
  SWK09 Zon Khas (Kampung Patarikan)

Terengganu:
  TRG01 Kuala Terengganu, Marang, Kuala Nerus
  TRG02 Besut, Setiu
  TRG03 Hulu Terengganu
  TRG04 Dungun, Kemaman

Wilayah Persekutuan:
  WLY01 Kuala Lumpur, Putrajaya
  WLY02 Labuan
	`
  fmt.println(zones)
}

fetch_prayers :: proc(zone: string = DEFAULT_ZONE) {
  data: rawptr = mem.alloc(1)
  defer free(data)

  url := API + DEFAULT_ZONE
  curl := ocurl.init()
  defer ocurl.cleanup(curl)

  ocurl.setopt(curl, ocurl.CurlOption.URL, url)
  ocurl.setopt(curl, ocurl.CurlOption.Httpget, 1)
  ocurl.setopt(curl, ocurl.CurlOption.Writedata, &data)
  ocurl.setopt(curl, ocurl.CurlOption.Writefunction, write_callback)

  fmt.println("Fetching data from Jakim...\n")

  if res := ocurl.perform(curl); res != ocurl.CurlCode.Ok {
    fmt.eprintf("Could not fetch data from Jakim: %d\n", res)
    os.exit(1)
  }

  response := (cast([^]byte)data)[:SIZE]
  prayers := Solat{}

  err := json.unmarshal(response, &prayers)
  assert(err == nil, "json unmarshall failed")

  current_day := time.day(time.now())

  for i := 0; i < len(prayers.PrayerTime); i += 1 {
    fmt.printf(
      "Tarikh:%s Imsak:%s Subuh:%s Syuruk:%s Zohor:%s Asar:%s Maghrib:%s Isya:%s",
      prayers.PrayerTime[i].Date,
      prayers.PrayerTime[i].Imsak,
      prayers.PrayerTime[i].Fajr,
      prayers.PrayerTime[i].Syuruk,
      prayers.PrayerTime[i].Dhuhr,
      prayers.PrayerTime[i].Asr,
      prayers.PrayerTime[i].Maghrib,
      prayers.PrayerTime[i].Isha,
    )

    if i + 1 == current_day do fmt.print(" ****")
    fmt.println()
  }
}

fetch_zone :: proc() {
  ok: bool
  zone: string

  if zone, ok = slice.get(os.args, 2); !ok {
    fmt.eprintln("Missing parameter for zone")
    fmt.eprintln("Please check help for usage")
    return
  }

  if ok := check_zones(zone); !ok {
    fmt.eprintf("Invalid zone value:`%s`\n", zone)
    fmt.eprintln("Please check help for valid value")
    return
  }

  fmt.printf("Choosing zone:`%s`\n", zone)
  fetch_prayers(zone)
}

fetch_default_zone :: proc() {
  fmt.println("Warning:no zone has been selected")
  fmt.printf("Choosing default zone:`%s`\n", DEFAULT_ZONE)
  fetch_prayers()
}

check_zones :: proc(zone: string) -> bool {
  zones := map[string]byte {
    "JHR01" = 1,
    "JHR02" = 1,
    "JHR03" = 1,
    "JHR04" = 1,
    "KDH01" = 1,
    "KDH02" = 1,
    "KDH03" = 1,
    "KDH04" = 1,
    "KDH05" = 1,
    "KDH06" = 1,
    "KDH07" = 1,
    "KTN01" = 1,
    "KTN02" = 1,
    "MLK01" = 1,
    "NGS01" = 1,
    "NGS02" = 1,
    "NGS03" = 1,
    "PHG01" = 1,
    "PHG02" = 1,
    "PHG03" = 1,
    "PHG04" = 1,
    "PHG05" = 1,
    "PHG06" = 1,
    "PLS01" = 1,
    "PNG01" = 1,
    "PRK01" = 1,
    "PRK02" = 1,
    "PRK03" = 1,
    "PRK04" = 1,
    "PRK05" = 1,
    "PRK06" = 1,
    "PRK07" = 1,
    "SBH01" = 1,
    "SBH02" = 1,
    "SBH03" = 1,
    "SBH04" = 1,
    "SBH05" = 1,
    "SBH06" = 1,
    "SBH07" = 1,
    "SBH08" = 1,
    "SBH09" = 1,
    "SGR01" = 1,
    "SGR02" = 1,
    "SGR03" = 1,
    "SWK01" = 1,
    "SWK02" = 1,
    "SWK03" = 1,
    "SWK04" = 1,
    "SWK05" = 1,
    "SWK06" = 1,
    "SWK07" = 1,
    "SWK08" = 1,
    "SWK09" = 1,
    "TRG01" = 1,
    "TRG02" = 1,
    "TRG03" = 1,
    "TRG04" = 1,
    "WLY01" = 1,
    "WLY02" = 1,
  }

  _, ok := zones[zone]
  return ok
}


main :: proc() {
  cmd := slice.get(os.args, 1) or_else "-default"

  switch cmd {
  case "-help":
    display_help()
  case "-zones":
    display_zones()
  case "-zone":
    fetch_zone()
  case "-default":
    fetch_default_zone()
  case:
    return
  }
}
