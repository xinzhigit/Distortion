Shader "Custom/DistortionMask(Billboard)" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Depth ("Depth", float) = 0
    }

    SubShader {
        Tags { 
            "RenderType" = "Transparent" 
            "Queue" = "Transparent+1"
            "DisableBatching" = "True"
        }
        ZWrite Off
        Cull Off

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            float _Depth;

            v2f vert (appdata v) {
                v2f o;

				// 公告牌
				float3 center = float3(0, 0, 0);
				float3 view = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
				float3 normalDir = normalize(view - center);
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));
				upDir = normalize(cross(normalDir, rightDir));
				float3 centerOff = v.vertex.xyz - center;
				v.vertex.xyz = center + rightDir * centerOff.x + center + upDir * centerOff.y + center + normalDir * centerOff.z;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                // 计算当前顶点的摄像机空间的深度（视椎体深度），范围[Near, Far]，这个值对应o.screenPos.z
                COMPUTE_EYEDEPTH(o.screenPos.z);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // 采样深度纹理并将其转换为线性
                float eyeDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
                float z = i.screenPos.z;

                // 比较深度，_Depth用于缓冲因遮挡而导致的扰动效果突变的现象
                // 将遮挡关系变为alpha值影响片元可见性，完成自定义深度测试
                float alpha = smoothstep(-_Depth, _Depth, eyeDepth - z);
                fixed4 col = tex2D(_MainTex, i.uv) * alpha;

                return col;
            }
            ENDCG
        }
    }
}
