Shader "GradientSkybox/Linear/Two Color" {
	Properties {
		_TopColor ("Top Color", Color) = (1, 0.3, 0.3, 0)
		_BottomColor ("Bottom Color", Color) = (0.3, 0.3, 1, 0)
		_Up ("Up", Vector) = (0, 1, 0)
		_Exp ("Exp", Range(0, 16)) = 1
	}
	SubShader {
		Tags {
			"RenderType" = "Background"
			"Queue" = "Background"
			"PreviewType" = "Skybox"
		}
		Pass {
			ZWrite Off
			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			fixed3 _TopColor, _BottomColor;
			float3 _Up;
			float _Exp;

			struct appdata {
				float4 vertex : POSITION;
				float3 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float3 texcoord : TEXCOORD0;
			};

			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				return o;
			}

			fixed4 frag (v2f i) : SV_TARGET {
				float3 texcoord = normalize(i.texcoord);
				float3 up = normalize(_Up);
				float d = dot(texcoord, up);
				return fixed4(lerp(_BottomColor, _TopColor, sign(d) * pow(abs(d), _Exp) * 0.5 + 0.5), 1);
			}

			ENDCG
		}
	}
	CustomEditor "GradientSkybox.LinearTwoColorGradientSkyboxGUI"
}