Shader "GradientSkybox/Circular/Multiple Color" {
	Properties {
		_RampTex ("Ramp Texture", 2D) = "white" {}
		[KeywordEnum(None, X, Y)] _Norm ("Normalization", Float) = 0
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

			struct appdata {
				float4 vertex : POSITION;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_TARGET {
				#if _NORM_X
					float2 uv = (i.vertex.xy / _ScreenParams.x - _ScreenParams.xy / _ScreenParams.x * 0.5) * 2;
				#elif _NORM_Y
					float2 uv = (i.vertex.xy / _ScreenParams.y - _ScreenParams.xy / _ScreenParams.y * 0.5) * 2;
				#else
					float2 uv = (i.vertex.xy / _ScreenParams.xy - 0.5) * 2;
				#endif
				return fixed4(tex2D(_RampTex, length(uv)).xyz, 1);
			}

			ENDCG
		}
	}
	CustomEditor "GradientSkybox.CircularMultipleColorGradientSkyboxGUI"
}