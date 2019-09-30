Shader "WormHole"
{
	Properties
	{
		_MainTex("MainTex",2D) = "white"{}
		_CenterX("CenterX", float) = -1.0
		_HoleDistance("HoleDistance", float) = 2.0
		//_CenterY("CenterY", float) = -1.0
	}
	
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct VertexInput
			{
				float4 vertex : POSITION;
				float2 uv:TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};

			struct VertexOutput
			{
				float4 pos : SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;
			float _CenterX;
			//float _CenterY;
			float _HoleDistance;
			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(VertexOutput vertex_output) : SV_Target
			{
				// normalized coordinates (-1 to 1 vertically)
				//float2 p = ((_CenterX + 2.0 * vertex_output.uv.x) / 1, (_CenterY + 2.0 * vertex_output.uv.y) / 1);
				float2 p = ((_CenterX + _HoleDistance * vertex_output.uv) / 1);

				// angle of each pixel to the center of the screen
				float a = atan2(p.x,p.y);

				// cylindrical tunnel
				float r = length(p);

				// index tex2D by (animated inverse) radius and angle
				float2 uv = float2(0.3 / r + 0.2 * _Time.y, a / 3.14);

				float2 uv2 = float2(uv.x, atan2(abs(p.x),abs(p.y)) / 3.14);
				float3 col = tex2Dgrad(_MainTex, uv, ddx(uv2), ddy(uv2)).xyz;

				// darken at the center    
				col = col * r;

				return float4(col, 1.0);
			}
			ENDCG
		}
	}
}
