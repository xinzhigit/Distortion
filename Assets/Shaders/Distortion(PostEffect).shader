Shader "Custom/Distortion(PostEffect)" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Noise Tex", 2D) = "white" {}
    }

    SubShader {
        ZWrite Off
        Cull Off

        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _MaskTex;
            float _DistortStrength;
			float _DistortVelocity;
			float _XDensity;
			float _YDensity;

            fixed4 frag(v2f_img i) : SV_Target {
                float2 noiseUV = i.uv * float2(_XDensity, _YDensity);
                noiseUV -= _Time.y * _DistortVelocity;

                float2 off = tex2D(_NoiseTex, noiseUV).rg;
                off = (off - 0.5) * 2 * _DistortStrength;

                i.uv += off * tex2D(_MaskTex, i.uv).r;

                return tex2D(_MainTex, i.uv);
            }

            ENDCG
        }
    }
}
