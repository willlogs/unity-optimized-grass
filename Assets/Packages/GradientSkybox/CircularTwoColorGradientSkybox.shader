Shader "GradientSkybox/Circular/Two Color" {
	Properties {
		_InnerColor ("Inner Color", Color) = (0.8, 0.8, 0.8, 0)
		_OuterColor ("Outer Color", Color) = (0.5, 0.5, 0.5, 0)
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
			#pragma multi_compile _NORM_NONE _NORM_X _NORM_Y

			fixed3 _InnerColor, _OuterColor;

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
				return fixed4(lerp(_InnerColor, _OuterColor, length(uv)), 1);
			}

			ENDCG
		}
	}
	CustomEditor "GradientSkybox.CircularTwoColorGradientSkyboxGUI"
}