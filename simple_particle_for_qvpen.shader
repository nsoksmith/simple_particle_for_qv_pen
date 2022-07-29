Shader "QvPen/Simple_particle_for_qv_pen"
{
    Properties
    {
		_Size ("Particle Size", Float) = 0.3
    }
    SubShader
    {
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100
		Cull Off
		Blend SrcAlpha One
		ZWrite Off

        Pass
        {
            CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
            };

            struct g2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 color : TEXCOORD1;
				float d : TEXCOORD2;
            };

            float rand3dTo1d(float3 value, float3 dotDir = float3(12.9898, 78.233, 37.719)){
                float3 smallValue = sin(value);
                float random = dot(smallValue, dotDir);
                random = frac(sin(random) * 143758.5453);
                return random;
            }

			float _Size;

            appdata vert(appdata v)
            {
                appdata o;
                return v;
            }

            [maxvertexcount(4)]
            void geom (point appdata input[1], inout TriangleStream<g2f> stream)
            {
                float4 point1 = input[0].vertex;
                g2f o;
                float size = 1;

                if(true) {
					o.color = input[0].color.rgb;
                    for (int i = 0; i < 2; i++){
                        float rand = rand3dTo1d(point1);
                        size = 2.0 + sin(rand*3.1415926535*2.0 + _Time.y*2*(1+rand));
                    }
					size *= _Size;
				}

                float p = 1;

                size *= 2;
                if(abs(UNITY_MATRIX_P[0][2]) < 0.01) size *= 2; 
                float sz = 0.002 * size;
                p *= sz;

				point1 = UnityObjectToClipPos(point1);
				float aspectRatio = - UNITY_MATRIX_P[0][0] / UNITY_MATRIX_P[1][1];

				o.d = 0;

                float py = p / aspectRatio;

                o.uv = float2(-1,-1);
				o.vertex = point1 + float4(-p,-py,0,0);
				stream.Append(o);
				o.uv = float2(-1,1);
				o.vertex = point1 + float4(-p, py,0,0);
				stream.Append(o);
				o.uv = float2(1,-1);
				o.vertex = point1 + float4( p,-py,0,0);
				stream.Append(o);
				o.uv = float2(1,1);
				o.vertex = point1 + float4( p, py,0,0);
				stream.Append(o);

				stream.RestartStrip();
            }

            fixed4 frag (g2f i) : SV_Target
            {
				float l = length(i.uv);
				clip(1-l);
				float3 color = lerp(fixed3(1,1,1), i.color, pow(l, 0.5));
				color *= pow(1 - l, 0.5 - i.d) * 2;
				color = min(1, color);
				color = pow(color, 2.2);
                return float4(color,smoothstep(1,0.8,l));
            }
            ENDCG
        }
    }
}
