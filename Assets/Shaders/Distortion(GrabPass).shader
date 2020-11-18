Shader "Custom/Distortion(GrabPass)" {
	Properties {
		_DistortStrength("热扰动强度", Range(0, 1)) = 0.5
		_DistortVelocity("热扰动速率", Range(0, 1)) = 0.5
		_XDensity("噪声密度（水平）", float) = 1
		_YDensity("噪声密度（竖直）", float) = 1
		_NoiseTex("噪声贴图", 2D) = "white" {}
		_MaskTex("噪声遮罩", 2D) = "Black" {}
	}

	SubShader {
		Tags {
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
			"DisableBatching" = "True"		// 批处理合并模型造成物体本地坐标丢失
		}
		ZWrite Off
		GrabPass{"_GrabTex"}				// 获取当前屏幕截图，并存入_GrabTex
		Cull Off

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f {
				float4 pos : SV_POSITION;
				float4 graPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
			};
			
			sampler2D _GrabTex;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			sampler2D _MaskTex;
			float _DistortStrength;
			float _DistortVelocity;
			float _XDensity;
			float _YDensity;

			v2f vert(appdata_base v) {
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

				// 热扰动
				o.pos = UnityObjectToClipPos(v.vertex);
				o.graPos = ComputeGrabScreenPos(o.pos);

				// 缩放纹理控制密度
				_NoiseTex_ST.xy *= float2(_XDensity, _YDensity);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _NoiseTex);
				o.uv.xy -= _Time.y * _DistortVelocity;
				o.uv.zw = v.texcoord;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				// 采样噪声，用rg两个通道的指做为两个方向上的偏移量
				float2 off = tex2D(_NoiseTex, i.uv.xy);

				// 原取得的值在0到1，重映射到-1到1， 增加扰动的随机感，并用_DistortStrength控制扰动强度
				off = (off - 0.5) * 2 * _DistortStrength;

				// 遮罩白色为正常扰动，黑色为无扰动
				i.graPos.xy += tex2D(_MaskTex, i.uv.zw).x * off;

				// 用偏移后的屏幕坐标抓取屏幕纹理
				fixed4 col = tex2Dproj(_GrabTex, i.graPos);

				return col;
			}

			ENDCG
		}
	}
}
