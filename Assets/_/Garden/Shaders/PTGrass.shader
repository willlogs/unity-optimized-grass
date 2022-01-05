Shader "PT/PTGrass"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _DirtTex("Dirt Texture", 2D) = "white" {}
        _GrassTex("Grass Texture", 2D) = "white" {}
        _NoGrassTex("No Grass Texture", 2D) = "white" {}
        _WindTex("Wind Texture", 2D) = "white" {}
        _BrushTex("Brush Texture", 2D) = "white" {}

        [Toggle] _hasNeath("hasNeath", Float) = 0

        _TopColor("Grass Top Color", Color) = (.25, .5, .5, 1)
        _BottomColor("Grass Bottom Color", Color) = (.25, .5, .5, 1)
        _BendRotationRandom("Bend Rotation Random", Range(0, 1)) = 0.2
        _RotationMultiplier("Bend Rotation Random", Range(1, 100)) = 20
        _BladeWidth("Blade Width", Float) = 0.05
        _BladeWidthRandom("Blade Width Random", Float) = 0.02
        _BladeHeight("Blade Height", Float) = 0.5
        _BladeHeightRandom("Blade Height Random", Float) = 0.3
        _TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
        _WindSource("Wind Source", Vector) = (0, 0, 0, 0)
        _WindRange("WindRange", Float) = 2.0
    }
    SubShader
    {
        Pass{
            Name "BaseGround"
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uvb : TEXCOORD1;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float2 uvb : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _DirtTex;
            sampler2D _BrushTex;
            sampler2D _NoGrassTex;
            float4 _MainTex_ST;
            float4 _BrushTex_ST;
            float _hasNeath;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvb = TRANSFORM_TEX(v.uvb, _BrushTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                if(_hasNeath > 0){
                    // sample the texture
                    float a = tex2D(_BrushTex, i.uvb).a;
                    fixed4 col = tex2D(_MainTex, i.uv) * a + tex2D(_DirtTex, i.uv) * (1 - a);
                    // apply fog
                    UNITY_APPLY_FOG(i.fogCoord, col);
                    return col;
                }

                return 0;
            }
            ENDCG
        }

        Pass{
            Name "GeometryGrass"

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM            
            #include "UnityCG.cginc"
            #include "Autolight.cginc"

            sampler2D _GrassTex;
            float4 _GrassTex_ST;

            sampler2D _NoGrassTex;
            float4 _NoGrassTex_ST;

            sampler2D _WindTex;
            float4 _WindTex_ST;
            
            #include "CustomTessellation.cginc"

            #pragma target 4.6
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            // make fog work
            // #pragma multi_compile_fog

            #pragma hull hull
            #pragma domain domain
            
            float4 _TopColor;
            float4 _BottomColor;
            float _BendRotationRandom;
            float _RotationMultiplier;

            float _BladeHeight;
            float _BladeHeightRandom;	
            float _BladeWidth;
            float _BladeWidthRandom;

            float4 _WindSource;
            float _WindRange;

            vertexOutput makevertex(float3 pos, float2 cuv, float2 uv){
                vertexOutput o;

                o.vertex = UnityObjectToClipPos(pos);
                o.uv = uv;
                o.cuv = cuv;
                o.normal = 0;
                o.tangent = 0;

                return o;
            }
            
            float rand(float3 myVector)  {
                return frac(sin(dot(myVector.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
            }

            float3x3 AngleAxis3x3(float angle, float3 axis)
            {
                float c, s;
                sincos(angle, s, c);

                float t = 1 - c;
                float x = axis.x;
                float y = axis.y;
                float z = axis.z;

                return float3x3(
                t * x * x + c, t * x * y - s * z, t * x * z + s * y,
                t * x * y + s * z, t * y * y + c, t * y * z - s * x,
                t * x * z - s * y, t * y * z + s * x, t * z * z + c
                );
            }

            [maxvertexcount(3)]
            void geom(triangle vertexInput IN[3], inout TriangleStream<vertexOutput> triStream)
            {
                float3 pos = IN[0].vertex;
                float3 vNormal = IN[0].normal;
                float4 vTangent = IN[0].tangent;
                float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;
                float3 alpha = 1 - tex2Dlod(_NoGrassTex, float4(IN[0].uv, 0, 0));
                
                float wind = tex2Dlod(_WindTex, float4(IN[0].uv, 0, 0)) / 2;

                if(alpha.x > 0.5){
                    float3x3 tangentToLocal = float3x3(
                    vTangent.x, vBinormal.x, vNormal.x,
                    vTangent.y, vBinormal.y, vNormal.y,
                    vTangent.z, vBinormal.z, vNormal.z
                    );

                    float3x3 bendRotationMatrix = AngleAxis3x3(
                    rand(pos.zzx) * _BendRotationRandom * sin(_Time[0] * _RotationMultiplier) * UNITY_PI * 0.5,
                    float3(-1, 0, 0)
                    );
                    float3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));

                    float3x3 transformationMatrix = tangentToLocal;
                    transformationMatrix = mul(transformationMatrix, facingRotationMatrix);
                    transformationMatrix = mul(transformationMatrix, bendRotationMatrix);

                    float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
                    float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;
                    
                    triStream.Append(
                        makevertex(
                            pos + mul(transformationMatrix, float3(width, 0, 0)),
                            float2(1, 0),
                            IN[0].uv
                        )
                    );
                    triStream.Append(makevertex(pos + mul(transformationMatrix, float3(-width, 0, 0)), float2(0, 0), IN[0].uv));
                    triStream.Append(makevertex(pos + mul(transformationMatrix, float3(0, 0, height * (1 - wind))), float2(0.5, 1), IN[0].uv));

                    triStream.RestartStrip();
                }
            }
            
            fixed4 frag (vertexOutput i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 col = tex2D(_GrassTex, i.uv);
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                col *= lerp(_BottomColor, _TopColor, i.cuv.y);
                return col;
            }
            ENDCG
        }
    }
}
