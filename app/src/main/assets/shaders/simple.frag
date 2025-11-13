precision mediump float;
varying vec2 vTexCoord;
uniform sampler2D uTexture;
void main() {
  vec4 c = texture2D(uTexture, vTexCoord);
  gl_FragColor = c;
}
