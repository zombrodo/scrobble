extern float totalTime;
float size = -1;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec4 texturecolor = Texel(tex, texture_coords);

    vec2 coords = texture_coords * 2.0 - 1;
    float time = fract(totalTime / 0.85);
    float radius = 2.2;

    float circle = max(size, length(coords));

    if(circle < time * radius){
      return texturecolor * vec4(0.125, 0.223, 0.309, 1.0);
    }

    return texturecolor * color;
}
