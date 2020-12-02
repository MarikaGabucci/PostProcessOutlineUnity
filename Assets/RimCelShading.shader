﻿Shader "Custom/RimCelShading"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
	    _Color ("Tint Color", Color) = (1, 1, 1, 1)
		_Antialiasing("Band Smoothing", Float) = 0.5
		_Glossiness("Glossiness/Shininess", Float) = 400
		_Fresnel("Rim Amount", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Cel

	    sampler2D _MainTex;
		sampler2D _BumpMap;
		fixed4 _Color;
		float _Antialiasing;
		float _Glossiness;
		float _Fresnel;

		float4 LightingCel(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			float3 normal = normalize(s.Normal);
			float diffuse = dot(normal, lightDir);

			float delta = fwidth(diffuse) * _Antialiasing;
			float diffuseSmooth = smoothstep(0, delta, diffuse);

			float3 halfVec = normalize(lightDir + viewDir);
			float specular = dot(normal, halfVec);
			specular = pow(specular * diffuseSmooth, _Glossiness);
			float specularSmooth = smoothstep(0, 0.01 * _Antialiasing, specular);

			float rim = 1 - dot(normal, viewDir);
			rim = rim * diffuse;
			float fresnelSize = 1 - _Fresnel;
			float rimSmooth = smoothstep(fresnelSize, fresnelSize * 1.1, rim);

			float3 col = s.Albedo * ((diffuseSmooth + specularSmooth + rimSmooth) * _LightColor0 + unity_AmbientSky);

			return float4(col, s.Alpha);
		}

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};

	    void surf (Input IN, inout SurfaceOutput o)
	    {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		    o.Albedo = c.rgb;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		}		



        ENDCG
    }

    FallBack "Diffuse"
}
