using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PT.Garden
{
    public class RTSetter : MonoBehaviour
    {
        public float percentage = 0;

        [SerializeField] private MeshRenderer _meshRenderer, _meshRenderer1;
        [SerializeField] private int _matIndex = 0, _matIndex1 = 0;
        [SerializeField] private string _mainTexName = "_MainTex";
        [SerializeField] private string _mainTexName1 = "_WindTex";
        private int _txid, _txid1;
        private Material _mainMaterial, _mainMaterial1;

        private void Start()
        {
            _mainMaterial = _meshRenderer.materials[_matIndex];
            _txid = Shader.PropertyToID(_mainTexName);

            _mainMaterial1 = _meshRenderer1.materials[_matIndex1];
            _txid1 = Shader.PropertyToID(_mainTexName1);

            _mainMaterial1.SetTexture(_txid1, _mainMaterial.GetTexture(_txid));
        }
    }
}