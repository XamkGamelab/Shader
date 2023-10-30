Shader "Custom/ProximityTexture"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _PlayerPosition("Player Position", Vector) = (0,0,0,0)
        _DistanceAttenuation("A thing", Range(1,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float3 _PlayerPosition;
            float _DistanceAttenuation;
            CBUFFER_END
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.uv = input.uv;
                return output;
            }
            
            float4 frag (Varyings input) : SV_TARGET
            {
                const float4 color1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv,_MainTex));
                
                float distance = length(_PlayerPosition - input.positionWS);
                distance = saturate(1 - distance / _DistanceAttenuation); // = clamp(distance, 0, 1);
                return lerp(0, (sin(distance * 30 + _Time.z * 2)+ 1) * 0.5f, distance);
            }
            ENDHLSL
        }
    }
}