<template>
  <div v-if="isOpen" class="black-bg">
    <div class="white-bg">
      <div class="modal-wrap">
        <div class="modal-header">
          <h3>설정</h3>
          <h3 @click="isOpen = !isOpen">&#10006;</h3>
        </div>
        <div class="modal-content">
          <div class="host-wrap">
            <span>host : </span>
            <input class="inp-ip" v-model="serverInfo.ip" type="text" />
          </div>
          <div class="port-wrap">
            <span>port : </span>
            <input class="inp-port" v-model="serverInfo.port" type="text" />
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" @click="updateServerInfo">적용</button>
        </div>
      </div>
    </div>
  </div>

  <div class="wrap">
    <div class="header">
      <h1 class="main-title">IDR PoC Test</h1>
    </div>
    <div class="content">
      <div class="upload-wrap">
        <div class="server-setting-wrap">
          <button type="button" @click="settingServer">설정</button>
        </div>
        <div class="filebox bs3-primary">
          <label for="ex_file_idCard">upload id card</label>
          <input
            type="file"
            id="ex_file_idCard"
            :key="idCardKey"
            @change="handleFileSelect($event, 'id_card')"
            multiple
          />
        </div>
        <div class="filebox bs3-primary">
          <label for="ex_file_passport">upload passport</label>
          <input
            type="file"
            id="ex_file_passport"
            :key="passportKey"
            @change="handleFileSelect($event, 'passport')"
            multiple
          />
        </div>
      </div>
      <div class="progress-wrap">
        <div class="progressBar">
          <div id="bar" class="innerbar" :style="{ width: progressWidth }"></div>
        </div>
        <div class="progressText">{{ Math.round(parseInt(progressWidth)) }}%</div>
      </div>
    </div>
  </div>
</template>
<script>
import axios from "axios";

export default {
  name: "WebHome",

  data() {
    return {
      isOpen: false,

      idCardKey: 0,
      passportKey: 0,

      selectedFiles: [], // 업로드 이미지 리스트

      serverInfo: {
        ip: "",
        port: "",
      },

      count: 0, // 현재 카운터
      totalCount: 0, // 진행률을 위한 카운터
      progressWidth: "0%", // progressbar 진행률

      registration: {
        type: "empty",
        number: "empty",
        issue_date: "empty",
        name : "empty",
        address : "empty",
      }, // 신분증
      driver_license: {
        type: "empty",
        class_type: "empty",
        license_number: "empty",
        number: "empty",
        issue_date: "empty",
        period: "empty",
        address: "empty",
        serial_number: "empty",
      }, // 운전면허증
      permanent_resident: {}, // 영주증
      aline_registration: {}, // 외국인등록증
      oversea_resident: {}, // 외국국적동포
      passport: {}, // 여권

      registrationCardList: [], // 신분증 리스트
      driverLicenseList: [], // 운전면허증 리스트
      permanentResidentList: [], // 영주증 리스트
      alineRegistrationList: [], // 외국인등록증 리스트
      overseaResidentList: [], // 외국국적동포 리스트
      passportList: [], // 여권 리스트
    };
  },

  mounted() {
    this.getServer();
    console.log("serverInfo : ", this.serverInfo);
  },

  methods: {
    getServer(){
      let getServerInfo = JSON.parse(localStorage.getItem("serverInfo"));

      if (getServerInfo !== null) {
        this.serverInfo = getServerInfo;
      }
    },

    updateServerInfo() {
      if (this.serverInfo.ip == "" || this.serverInfo.port == "") {
        alert("ip와 port 정보를 모두 입력해주세요.");
        return;
      }

      let item = JSON.stringify(this.serverInfo);
      localStorage.setItem("serverInfo", item);
      this.getServer();

      alert("ip와 port를 설정 완료하였습니다.");
    },

    settingServer() {
      this.isOpen = !this.isOpen;
      document.body.style.overflow = "hidden";

      this.getServer();
    },

    async handleFileSelect(event, target) {
      if (this.serverInfo.ip == "" || this.serverInfo.port == "") {
        alert("ip 또는 port 정보가 없습니다.");
        return;
      }
      let url = "";

      if (target === "id_card") {
        this.idCardKey += 1;
        // 172.25.10.72:9005/idr
        // 192.168.20.203:9005/idr
        url =
          // `http://${this.serverInfo.ip}:${this.serverInfo.port}/icr/recognize_korean_idr?head_portrait=1&crop_image=1&char_position=1`;
          `http://${this.serverInfo.ip}:${this.serverInfo.port}/idr`;
      } else if (target === "passport") {
        this.passportKey += 1;
        // 172.25.10.72:9005/idrpassport
        // 192.168.20.203:9005/idrpassport
        url =
          // `http://${this.serverInfo.ip}:${this.serverInfo.port}/cci_ai/service/v1/passport?head_portrait=1&crop_image=1&char_position=1`;
          `http://${this.serverInfo.ip}:${this.serverInfo.port}/idrpassport`;
      }

      console.log('url : ', url);

      target = "";

      const config = {
        headers: {
          "Content-Type": "multipart/form-data",
          id: "IDRPoC", // id 추가
          key: "aae49802e555", // key 추가
          // "Access-Control-Allow-Origin": "*", // CORS 관련 헤더 추가
          // "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE", // 허용된 메서드 지정
          // "Access-Control-Allow-Headers": "Content-Type, Authorization" // 허용된 요청 헤더 지정
        },
      };

      this.selectedFiles = Array.from(event.target.files);
      this.totalCount = this.selectedFiles.length;

      for (let i = 0; i < this.selectedFiles.length; i++) {
        const file = this.selectedFiles[i];
        const formData = new FormData();

        this.itemClear();

        formData.append("file", file);
        await axios
          .post(url, formData, config)
          .then((res) => {
            if (res.data.code == 200) {
              this.count++;
              this.progressWidth = ((i + 1) / this.totalCount) * 100 + "%";

              let item = res.data.result;

              console.log("res : ", item);
              if (item.type == "registration_card") {
                // 신분증
                item.item_list[0].value !== '' ? this.registration.type = item.item_list[0].value : this.registration.type = 'empty';
                item.item_list[1].value !== '' ? this.registration.number = item.item_list[1].value : this.registration.number = 'empty';
                item.item_list[2].value !== '' ? this.registration.issue_date = item.item_list[2].value : this.registration.issue_date = 'empty';
                item.item_list[3].value !== '' ? this.registration.name = item.item_list[3].value : this.registration.name = 'empty';
                item.item_list[4].value !== '' ? this.registration.address = item.item_list[4].value : this.registration.address = 'empty';

                this.registrationCardList.push(this.registration);
              } else if (item.type == "driver's_license") {
                // 운전면허증
                item.item_list[0].value !== '' ? this.driver_license.type = item.item_list[0].value : this.driver_license.type = 'empty';
                item.item_list[1].value !== '' ? this.driver_license.class_type = item.item_list[0].value : this.driver_license.class_type = 'empty';
                item.item_list[2].value !== '' ? this.driver_license.license_number = item.item_list[0].value : this.driver_license.license_number = 'empty';
                item.item_list[3].value !== '' ? this.driver_license.number = item.item_list[0].value : this.driver_license.number = 'empty';
                if (item.item_list[4].description == "Date Issued") {
                  item.item_list[4].value !== '' ? this.driver_license.issue_date = item.item_list[4].value : this.driver_license.issue_date = 'empty';
                  item.item_list[5].value !== '' ? this.driver_license.period = item.item_list[5].value : this.driver_license.period = 'empty';
                  item.item_list[6].value !== '' ? this.driver_license.name = item.item_list[6].value : this.driver_license.name = 'empty';
                  item.item_list[7].value !== '' ? this.driver_license.address = item.item_list[7].value : this.driver_license.address = 'empty';
                  item.item_list[8].value !== '' ? this.driver_license.serial_number = item.item_list[8].value : this.driver_license.serial_number = 'empty';

                } else if (item.item_list[4].description == 'Serial Number') {
                  item.item_list[5].value !== '' ? this.driver_license.issue_date = item.item_list[5].value : this.driver_license.issue_date = 'empty';
                  item.item_list[6].value !== '' ? this.driver_license.period = item.item_list[6].value : this.driver_license.period = 'empty';
                  item.item_list[7].value !== '' ? this.driver_license.name = item.item_list[7].value : this.driver_license.name = 'empty';
                  item.item_list[8].value !== '' ? this.driver_license.address = item.item_list[8].value : this.driver_license.address = 'empty';
                  item.item_list[4].value !== '' ? this.driver_license.serial_number = item.item_list[4].value : this.driver_license.serial_number = 'empty';
                }
                this.driverLicenseList.push(this.driver_license);
              } else if (item.type.includes("permanent_resident")) {
                // 영주증
                this.permanent_resident.type = item.item_list[0].value;
                this.permanent_resident.number = item.item_list[1].value;
                this.permanent_resident.status = item.item_list[2].value;
                this.permanent_resident.country = item.item_list[3].value;
                this.permanent_resident.name = item.item_list[4].value;
                this.permanent_resident.issue_date = item.item_list[5].value;
                this.permanent_resident.gender = item.item_list[6].value;
                this.permanent_resident.water_code = item.item_list[7].value;
                this.permanentResidentList.push(this.permanent_resident);
              } else if (item.type.includes("aline_registration")) {
                // 외국인등록증
                this.aline_registration.type = item.item_list[0].value;
                this.aline_registration.number = item.item_list[1].value;
                this.aline_registration.status = item.item_list[2].value;
                this.aline_registration.country = item.item_list[3].value;
                this.aline_registration.name = item.item_list[4].value;
                this.aline_registration.issue_date = item.item_list[5].value;
                item.item_list[6].value !== ""
                  ? (this.aline_registration.gender = item.item_list[6].value)
                  : (this.aline_registration.gender = "empty");
                this.alineRegistrationList.push(this.aline_registration);
              } else if (item.type.includes("oversea_resident")) {
                // 외국국적동포 국내거소신고증
                this.oversea_resident.type = item.item_list[0].value;
                this.oversea_resident.number = item.item_list[1].value;
                this.oversea_resident.status = item.item_list[2].value;
                this.oversea_resident.country = item.item_list[3].value;
                this.oversea_resident.name = item.item_list[4].value;
                this.oversea_resident.issue_date = item.item_list[5].value;
                this.oversea_resident.gender = item.item_list[6].value;
                this.oversea_resident.water_code = item.item_list[7].value;
                this.overseaResidentList.push(this.oversea_resident);
              } else if (item.type.includes("passport")) {
                // 여권
                item.item_list[0].value !== '' ? this.passport.passport_number = item.item_list[0].value : this.passport.passport_number = 'empty';
                item.item_list[1].value !== '' ? this.passport.gender = item.item_list[1].value : this.passport.gender = 'empty';
                item.item_list[3].value !== '' ? this.passport.name = item.item_list[3].value : this.passport.name = 'empty';
                item.item_list[4].value !== '' ? this.passport.birthday = item.item_list[4].value : this.passport.birthday = 'empty';
                item.item_list[5].value !== '' ? this.passport.validity = item.item_list[5].value : this.passport.validity = 'empty';
                item.item_list[6].value !== '' ? this.passport.passport_nation = item.item_list[6].value : this.passport.passport_nation = 'empty';
                item.item_list[10].value !== '' ? this.passport.passport_line1 = item.item_list[10].value : this.passport.passport_line1 = 'empty';
                item.item_list[11].value !== '' ? this.passport.passport_line2 = item.item_list[11].value : this.passport.passport_line2 = 'empty';
                item.item_list[13].value !== '' ? this.passport.surname = item.item_list[13].value : this.passport.surname = 'empty';
                item.item_list[14].value !== '' ? this.passport.given_name = item.item_list[14].value : this.passport.given_name = 'empty';
                item.item_list[15].value !== '' ? this.passport.country_code = item.item_list[15].value : this.passport.country_code = 'empty';

                //this.passport.pinyin = item.item_list[2].value;
                // this.passport.issue_date = item.item_list[7].value;
                // this.passport.birthplace = item.item_list[8].value;
                // this.passport.issue_place = item.item_list[9].value;
                // this.passport.issued_by = item.item_list[12].value;
                this.passportList.push(this.passport);
              }
            } else {
              alert(res);
            }
          })
          .catch((error) => {
            console.log('error : ', error);
          });
      }

      if (this.registrationCardList.length > 0) {
        const registrationCardFileName = this.generateFileName("주민등록증");
        this.downloadCSV(this.registrationCardList, registrationCardFileName);
      }
      if (this.driverLicenseList.length > 0) {
        const driverLicenseFileName = this.generateFileName("운전면허증");
        this.downloadCSV(this.driverLicenseList, driverLicenseFileName);
      }
      if (this.permanentResidentList.length > 0) {
        const permanentResidentFileName = this.generateFileName("영주증");
        this.downloadCSV(this.permanentResidentList, permanentResidentFileName);
      }
      if (this.alineRegistrationList.length > 0) {
        const alineRegistrationFileName = this.generateFileName("외국인등록증");
        this.downloadCSV(this.alineRegistrationList, alineRegistrationFileName);
      }
      if (this.overseaResidentList.length > 0) {
        const overseaResidentFileName = this.generateFileName(
          "외국국적동포 국내거소신고증"
        );
        this.downloadCSV(this.overseaResidentList, overseaResidentFileName);
      }
      if (this.passportList.length > 0) {
        const passportFileName = this.generateFileName("여권");
        this.downloadCSV(this.passportList, passportFileName);
      }

      if (this.count == this.totalCount) {
        setTimeout(async () => {
          alert("recognition is complete.");
          await this.listClear();
        }, 500);
      }
    },

    itemClear() {
      this.registration = {};
      this.driver_license = {};
      this.permanent_resident = {};
      this.aline_registration = {};
      this.oversea_resident = {};
      this.passport = {};
    },

    async listClear() {
      this.count = 0;
      this.progressWidth = "0%";
      this.registrationCardList = [];
      this.driverLicenseList = [];
      this.permanentResidentList = [];
      this.alineRegistrationList = [];
      this.overseaResidentList = [];
      this.passportList = [];
    },

    generateFileName(baseName) {
      const currentDate = new Date();
      const timestamp = currentDate
        .toISOString()
        .slice(0, 19)
        .replace(/[-T:/]/g, "");
      return `${baseName}_${timestamp}.csv`;
    },

    // CSV 문자열을 생성하는 함수
    convertToCSV(data) {
      const header = Object.keys(data[0]).join(",") + "\n";
      const body = data
        .map((item) => {
          const values = Object.values(item).map((value) => {
            // 만약 값에 쉼표가 있다면 공백으로 대체하여 반환
            if (typeof value === "string" && value.includes(",")) {
              return value.replace(/,/g, "");
            }
            return value;
          });
          return values.join(",");
        })
        .join("\n");
      return header + body;
    },

    // CSV 파일을 다운로드하는 함수
    downloadCSV(data, filename) {
      const csv = this.convertToCSV(data);
      const csvBlob = new Blob(["\ufeff" + csv], { type: "text/csv" });
      const link = document.createElement("a");
      link.href = window.URL.createObjectURL(csvBlob);
      link.setAttribute("download", filename);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    },
  },
};
</script>
<style>
@import "../style/main.css";
</style>
