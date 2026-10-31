varying vec2 v_vTexcoord;
varying vec4 v_vColour;
void main() {
    vec4 c=texture2D(gm_BaseTexture,v_vTexcoord);
    // The supplied sheet has an uneven white matte, not an alpha background.
    if(min(c.r,min(c.g,c.b))>0.74)discard;
    gl_FragColor=v_vColour*c;
}
