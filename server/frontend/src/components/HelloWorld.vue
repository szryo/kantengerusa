<template>
  <div class="hello">
    <h1>ぬいぐるみ</h1>
    <button v-on:click="CameraManeger()">{{camera_msg}}</button><br>
    {{video_toggle_msg}}
    <toggle-button
                @change="ToggleEventHandler"
                 :value="true"
                 :color= "{checked: '#00FF00', unchecked: '#FF0000', disabled: '#CCCCCC'}"
    ></toggle-button>
    <video id = "video" width="400" height="400"></video>

    {{emotion}}
    <line-chart :chart-data="datacollection"></line-chart>
    <div v-show= false>
      <canvas  id="emo_canvas" width="400" height="400"></canvas>
    </div>
  </div>
</template>

<script>

import Vue from 'vue';
import Axios from 'axios';
import VueAxios from 'vue-axios'

import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { collection, addDoc,Timestamp} from "firebase/firestore";

//import { Bar } from 'vue-chartjs'

import 'firebase/firestore';
Vue.use(VueAxios, Axios)

import ToggleButton from 'vue-js-toggle-button'
Vue.use(ToggleButton)

import LineChart from './LineChart.js'

const firebaseApp = initializeApp({
  apiKey: "xxx",
  authDomain: "xxx",
  projectId: "xxx",
});

console.log(firebaseApp);
const db = getFirestore();

export default {
  name: 'HelloWorld',
  props: {
    msg: String
  },
  components:{
    LineChart,
  },
  data(){
    return{
      name:"hello",
      captures: [],
      testTimer: '',
      canvas: {},
      video:{},
      emotion:{},
      is_camera:false,
      camera_msg:"start",
      toggle_value:false,
      video_toggle_msg:"画面共有",

      datacollection: null,
      chart_data:{"happiness": [0], "neutral": [0], "others": [0]},//
      chart_label:[],
    }
  },
  mounted () {
      this.fillData()
      this.video = document.getElementById("video");
    },
  methods:{
    fillData () {
      this.chart_label.push(this.getDate());
      this.datacollection = {
        labels: this.chart_label,
        datasets: [
          {
            label: 'happiness',
            data: this.chart_data["happiness"],
            fill:false,
            borderColor:'rgba(255, 99, 132, 0.8)',
          },
          {
            label: 'neutral',
            data: this.chart_data["neutral"],
            fill:false,
            borderColor:'rgba(54, 162, 235, 0.8)',
          }, 
          {
            label: 'others',
            data: this.chart_data["others"],
            fill:false,
            borderColor:'rgba(255, 206, 86, 0.8)',
          }, 

        ]
      }
    },
    getRandomInt () {
      let tmp = Math.floor(Math.random() * (50 - 5 + 1)) + 5

      console.log(tmp);
      return tmp
    },
    getDate(){
    const date =new Date()
    let d =  ('0' + date.getHours()).slice(-2)
    d+= ':' + ('0' + date.getMinutes()).slice(-2)
    d+= ':' + ('0' + date.getSeconds()).slice(-2);
    console.log(d)
    return d
    },
    CameraManeger:async function(){
      if(this.is_camera){
        this.stopCamera()
        this.camera_msg = "start"
      }
      else{
        if(this.toggle_value){
          await this.startCamera();
        }
        else{
          await this.startCapture();
        }
      }
    },
    ToggleEventHandler:function(){
      this.toggle_value= !this.toggle_value;
      if(this.toggle_value){
        this.video_toggle_msg="カメラ";
      }
      else{
        this.video_toggle_msg="画面共有";
      }
      this.is_camera=true;
      this.CameraManeger();
    },
    startCamera:async function(){

      navigator.mediaDevices.getUserMedia({
          video: true,
          audio: false,
      }).then(stream => {
          this.video.srcObject = stream;
          this.video.play();
          console.log("test");
          this.is_camera=true;
          this.camera_msg = "stop";

          this.getCamera();
      }).catch(e => {
        console.log(e);
      })
    },
    stopCamera:function(){
      this.video.pause();
      this.is_camera=false
    },
    startCapture:async function(){
      
      navigator.mediaDevices.getDisplayMedia({
        audio: false, 
        video: true
      }).then(stream=> {
          this.video.srcObject = stream;
          this.video.play();
          console.log("test");
          if(this.is_camera == false){
            this.is_camera=true;
            this.camera_msg = "stop";

            this.getCamera();
          }
      }).catch(e => {
        console.log(e);
      });
    },

    getCamera: async function(){
      const canvas = document.getElementById("emo_canvas");
      // console.log(this.$refs.canvas)
      //let context = 
      canvas.getContext("2d").drawImage(this.video, 0, 0, 400, 240);
      //撮った画像をcaptures配列に格納する
      this.captures.push(canvas.toDataURL("image/png")) ;
      let subscriptionKey = "53adb7f04dab48e8a81837a179b7d087";
      let uriBase = "https://m1gpemorec.cognitiveservices.azure.com/face/v1.0/detect";
      // let params = {
      //   "returnFaceId": "true",
      //   "returnFaceLandmarks": "false",
      //   "returnFaceAttributes":
      //     "emotion"
      // };
      //配列最後に追加された画像のフォーマットを変換し、imgURL変数に代入する
      console.log("start");
      const imgURL = this.makeblob(this.captures[this.captures.length - 1]);
      console.log(imgURL);
      //imgURLの画像をFaceAPIに送信
      let getEmo = false;
      await Axios.post(
        uriBase + "?returnFaceId=true&returnFaceLandmarks=false&returnFaceAttributes=age,emotion&recognitionModel=recognition_03&detectionModel=detection_01",
        imgURL,
        {
          headers: {
            "Content-Type": "application/octet-stream",
            "Ocp-Apim-Subscription-Key": subscriptionKey
          },
          //data:
        },
      )
      .then(response => {
        this.emotion=response.data[0].faceAttributes.emotion;
        getEmo = true;
        
      })
      .catch(error => {
        console.log(error);
        console.log(error.response);
      });
      if(getEmo){
        console.log(this.emotion);
        this.chart_data["others"].push(0)
        for (let key in this.emotion) {
          if(key == "happiness" || key == "neutral"){
            this.chart_data[key].push(this.emotion[key])
          }
          else{
            this.chart_data["others"][this.chart_data["others"].length - 1]+=this.emotion[key]
          }
        }
        this.fillData();
        this.emotion["time"]=Timestamp.now();
        await this.addf_store(this.emotion);
      }
      const sleep = msec => new Promise(resolve => setTimeout(resolve, msec));
      let i = 0;
      while(i<50 && this.is_camera){
        await sleep(100);
        i++;
      }
      if(this.is_camera){
        this.getCamera();
      }
    },


    makeblob: function (dataURL) {
        let BASE64_MARKER = ';base64,';

        console.log("changed");
        if (dataURL.indexOf(BASE64_MARKER) == -1) {
          let parts = dataURL.split(',');
          let contentType = parts[0].split(':')[1];
          let raw = decodeURIComponent(parts[1]);
          return new Blob([raw], {type: contentType});
        }
        let parts = dataURL.split(BASE64_MARKER);
        let contentType = parts[0].split(':')[1];
        let raw = window.atob(parts[1]);
        let rawLength = raw.length;
        let uInt8Array = new Uint8Array(rawLength);
        for (let i = 0; i < rawLength; ++i) {
          uInt8Array[i] = raw.charCodeAt(i);
        }
        console.log("changed");
        return new Blob([uInt8Array], {type: contentType})
    },
    addf_store: async function(emo_json){

      try {
        const docRef = await addDoc(collection(db, "kimata"), emo_json);
        console.log("Document written with ID: ", docRef.id);
      } catch (e) {
        console.error("Error adding document: ", e);
      }
    },
    
  },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
