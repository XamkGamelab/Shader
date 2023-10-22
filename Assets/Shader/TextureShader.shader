Shader "Custom/TextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpeedX ("SpeedX", Float) = 0
        _SpeedY ("SpeedY", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
                
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
            float4 _MainTex_ST;
            float _SpeedX;
            float _SpeedY;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD2;
            };
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw + _Time.y * float2(_SpeedX, _SpeedY);
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
