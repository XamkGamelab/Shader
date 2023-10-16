Shader "Custom/TextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        
        HLSLINCLUDE

        
            
        ENDHLSL
        
        Pass
        {
            
            HLSLPROGRAM            
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Shininess;
            float4 _MainTex_ST;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw + _Time.y * float2(0.5,0.1);
                return output;
            }
            
            float4 frag(Varyings input) : SV_Target
            {
                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
            }
            
            ENDHLSL
            
        }
        
        Pass
        {
        Name "Depth"
        Tags { "LightMode" = "DepthOnly" }
    
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask R
    
        HLSLPROGRAM
    
        #pragma vertex DepthVert
        #pragma fragment DepthFrag

        #include "Common/DepthOnly.hlsl"

        ENDHLSL

        }
        
        Pass
        {
        Name "Normals"
        Tags { "LightMode" = "DepthNormalsOnly" }
    
        Cull Back
        ZTest LEqual
        ZWrite On
    
        HLSLPROGRAM
    
        #pragma vertex DepthNormalsVert
        #pragma fragment DepthNormalsFrag

        #include "Common/DepthNormalsOnly.hlsl"
    
        ENDHLSL
        }
    }
}
