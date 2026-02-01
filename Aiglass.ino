#include <WiFi.h>
#include <driver/i2s.h>
#include <WiFiUdp.h>

// ====== ขา I2S ======
#define I2S_WS   5
#define I2S_SD   6
#define I2S_SCK  4

// ====== WiFi + UDP ======
const char* ssid     = "";
const char* password = "";
const char* udpIp    = ""; // IP เครื่อง Python
const int   udpPort  = 12345;

// ====== ปุ่ม ======
const int buttonPin = 7;
bool isRecording = false;

// ====== UDP ======
WiFiUDP udp;

// ====== การตั้งค่า I2S ======
i2s_config_t i2s_config = {
  .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
  .sample_rate = 16000,
  .bits_per_sample = I2S_BITS_PER_SAMPLE_32BIT,
  .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
  .communication_format = I2S_COMM_FORMAT_I2S_MSB,
  .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
  .dma_buf_count = 8,
  .dma_buf_len = 1024,
  .use_apll = false,
  .tx_desc_auto_clear = false,
  .fixed_mclk = 0
};

i2s_pin_config_t pin_config = {
  .bck_io_num = I2S_SCK,
  .ws_io_num = I2S_WS,
  .data_out_num = I2S_PIN_NO_CHANGE,
  .data_in_num = I2S_SD
};

void setup() {
  Serial.begin(115200);
  pinMode(buttonPin, INPUT_PULLUP);

  // ====== เชื่อม WiFi ======
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi connected");

  // ====== ติดตั้ง I2S ======
  i2s_driver_install(I2S_NUM_0, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_NUM_0, &pin_config);

  // ====== เริ่ม UDP ======
  udp.begin(udpPort);
  Serial.println("UDP ready");
}

void loop() {
  // ตรวจสอบปุ่มกดเพื่อบันทึกเสียง
  if (digitalRead(buttonPin) == LOW && !isRecording) {
    isRecording = true;
    Serial.println("🎤 เริ่มบันทึกเสียง...");

    size_t bytes_read;
    uint32_t i2s_buffer[1024]; // buffer สำหรับข้อมูลเสียง

    // ⬅️ กดค้างเพื่อบันทึกเสียงต่อเนื่อง
    while (digitalRead(buttonPin) == LOW) {
      i2s_read(I2S_NUM_0, (char*)i2s_buffer, sizeof(i2s_buffer), &bytes_read, portMAX_DELAY);

      // ส่งเสียงผ่าน UDP
      udp.beginPacket(udpIp, udpPort);
      udp.write((uint8_t*)i2s_buffer, bytes_read);
      udp.endPacket();
    }

    // ส่งสัญญาณจบเสียง
    udp.beginPacket(udpIp, udpPort);
    udp.print("END");
    udp.endPacket();

    Serial.println("✋ จบการบันทึกเสียง");
    isRecording = false;
  }
}


