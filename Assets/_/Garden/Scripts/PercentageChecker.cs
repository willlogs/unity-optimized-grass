using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace PT.Garden{
    public class PercentageChecker : MonoBehaviour
    {
        [SerializeField] private float percentage;
        private float[] results;

        [SerializeField] private ComputeShader _cs;
        [SerializeField] private Color _refree;
        [SerializeField] private MeshRenderer _meshRenderer;
        [SerializeField] private int _matIndex = 0;
        [SerializeField] private string _mainTexName = "_NoGrassTex";
        [SerializeField] private float _betweenReads = 0.5f;
        [SerializeField] private bool _run;
        private int _txid;
        private Material _mainMaterial;
        private Texture _texture;
        private bool _isChecking = true, _checkSig = false;
        private int width, height;
        private Color[] colors;
        [SerializeField] int kernelindex;
        [SerializeField] private Image _filledSlider;
        private ComputeBuffer sumBuffer;

        private void Start(){
            _mainMaterial = _meshRenderer.materials[_matIndex];
            _txid = Shader.PropertyToID(_mainTexName);
            kernelindex = _cs.FindKernel("CSMain");
            _texture = _mainMaterial.GetTexture(_txid);
            results = new float[_texture.width * _texture.height];
            sumBuffer = new ComputeBuffer(results.Length, sizeof(float));
        }
        
        private void Update(){
            _run = false;
            
            // get the texture
            _texture = _mainMaterial.GetTexture(_txid);
            RenderTexture t = (RenderTexture)_texture;

            RenderTexture rt = new RenderTexture(t.width, t.height, t.depth, t.format);
            rt.enableRandomWrite = true;
            rt.Create();

            RenderTexture currentRT = RenderTexture.active;
            RenderTexture.active = t;
            
            // copy the texture
            Graphics.Blit(t, rt);

            RenderTexture.active = currentRT;
            
            _cs.SetBuffer(kernelindex, "diffSum", sumBuffer);
            _cs.SetFloat("resolution", rt.width);
            _cs.SetTexture(kernelindex, "Input", rt);
            _cs.Dispatch(kernelindex, _texture.width / 8, _texture.height / 8, 1);
            sumBuffer.GetData(results);

            float sum = 0;
            for(int i = 0; i < results.Length; i++){
                sum += results[i];
            }

            percentage = sum / results.Length;
            _filledSlider.fillAmount = percentage;

            if(percentage > 0.95){
                // win
                int idx = SceneManager.GetActiveScene().buildIndex;
                if(idx == SceneManager.sceneCount - 1){
                    idx = 0;
                }
                SceneManager.LoadScene(idx + 1);
            }
        }

        private void OnDestroy(){
            if(sumBuffer != null)
                sumBuffer.Dispose();
        }
    }
}