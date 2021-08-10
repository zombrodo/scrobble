vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
  vec4 texture_color = Texel(tex, texture_coords);
  float alpha = texture_color.w == 0 ? 0 : 0.99 - texture_coords.y;
  vec4 newColor = vec4(texture_color.x, texture_color.y, texture_color.z, alpha);
  return newColor;
}
