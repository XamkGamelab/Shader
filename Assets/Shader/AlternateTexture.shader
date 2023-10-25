Shader "Custom/AlternateTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecTex ("Texture2", 2D) = "white" {}
        _CutPoint ("Cut point", Range(0,1)) = 0.5
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

            //TEXTURE2D(_MainTex);
            //SAMPLER(sampler_MainTex);
            sampler2D _MainTex;
            sampler2D _SecTex;
            float4 _Color;
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _SpeedX;
            float _SpeedY;
            float4 _SecTex_ST;
            float _CutPoint;
            CBUFFER_END

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD2;
            };
            
            v2f vert (appdata input)
            {
                v2f output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                
                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw + _Time.y * float2(_SpeedX, _SpeedY);
                return output;
            }
            
            float4 frag(v2f input) : SV_Target
            {
                float4 tex1 = tex2D(_MainTex, input.uv);
                float4 tex2 = tex2D(_SecTex, input.uv);
                
                float4 result = lerp(tex2, tex1, _CutPoint < (input.uv.x * _SecTex_ST.x + input.uv.y * _SecTex_ST.y) % 1);
                
                return result;
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
