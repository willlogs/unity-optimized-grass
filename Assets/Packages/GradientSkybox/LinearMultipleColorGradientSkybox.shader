Shader "GradientSkybox/Linear/Multiple Color" {
	Properties {
		_RampTex ("Ramp Texture", 2D) = "white" {}
		_Up ("Up", Vector) = (0, 1, 0)
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

			sampler2D _RampTex;
			float3 _Up;

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
				float2 uv = float2(dot(texcoord, up) * 0.5 + 0.5, 0);
				return fixed4(tex2D(_RampTex, uv).xyz, 1);
			}

			ENDCG
		}
	}
	CustomEditor "GradientSkybox.LinearMultipleColorGradientSkyboxGUI"
}