#include <WiFi.h>
#include <driver/i2s.h>
#include <WiFiUdp.h>
#include <WebServer.h>

// ====== I2S (INMP441) ======
#define I2S_WS   25   // WS / LRCLK
#define I2S_SD   22   // SD / DOUT
#define I2S_SCK  26   // BCLK

// ====== WiFi + UDP ======
const char* ssid     = "";
const char* password = "";
const char* udpIp    = ""; // IP เครื่อง Python
const int   udpPort  = 12345;

// ====== (Optional) simple web server for LED control ======
WebServer server(80);
const int LED_PIN = 2;

// ====== UDP ======
WiFiUDP udp;

// ====== I2S config (for INMP441 typical) ======
i2s_config_t i2s_config = {
  .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
  .sample_rate = 16000,
  .bits_per_sample = I2S_BITS_PER_SAMPLE_32BIT,
  .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
  .communication_format = I2S_COMM_FORMAT_I2S,
  .intr_alloc_flags = 0,
  .dma_buf_count = 4,
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

void handle_on(){
  digitalWrite(LED_PIN, HIGH);
  server.send(200, "text/plain", "LED ON");
}
void handle_off(){
  digitalWrite(LED_PIN, LOW);
  server.send(200, "text/plain", "LED OFF");
}

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  // WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected: " + WiFi.localIP().toString());

  // I2S init
  i2s_driver_install(I2S_NUM_0, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_NUM_0, &pin_config);

  // UDP begin (we only send, so port here is optional)
  udp.begin(udpPort);
  Serial.println("UDP ready to send to " + String(udpIp) + ":" + String(udpPort));

  // Simple HTTP endpoints for control
  server.on("/led/on", HTTP_GET, handle_on);
  server.on("/led/off", HTTP_GET, handle_off);
  server.begin();
}

void loop() {
  // non-blocking handling of the webserver
  server.handleClient();

  // read i2s buffer and send via UDP continuously
  const size_t buf_samples = 1024; // number of 32-bit samples per read
  uint32_t i2s_buffer[buf_samples];
  size_t bytesRead = 0;

  esp_err_t ret = i2s_read(I2S_NUM_0, (void*)i2s_buffer, sizeof(i2s_buffer), &bytesRead, portMAX_DELAY);
  if (ret == ESP_OK && bytesRead > 0) {
    // send the raw bytes as-is (32-bit LE PCM)
    udp.beginPacket(udpIp, udpPort);
    udp.write((uint8_t*)i2s_buffer, bytesRead);
    udp.endPacket();
  }
  // loop continues, streaming audio forever
}
