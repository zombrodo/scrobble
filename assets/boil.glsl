#pragma language glsl3

extern float noiseScale = 1.1;
extern float noiseSnap = 0.4;
extern float extraRandom = 0;
extern float timeElapsed;

float rand(float n)
{
    return fract(sin(n) * 43758.5453123);
}

float snap(float x, float snap) {
  return snap * round(x / snap);
}

vec4 position(mat4 transform, vec4 vertexPosition) {
  float time = snap(timeElapsed, noiseSnap);

  vec2 noise;
  noise.x = rand(vertexPosition.x + time) + rand(extraRandom);
  noise.y = rand(vertexPosition.y + time) + rand(extraRandom);
  noise *= noiseScale;

  vertexPosition.xy += noise;

  return transform * vertexPosition;
}